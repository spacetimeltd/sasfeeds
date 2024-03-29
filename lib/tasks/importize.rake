require 'csv'
require 'pry'
require 'action_view'
require 'fileutils'

# gen_sas goes first, then sasmap needs to be generated from the header
# after that asproducts, wsproduct, maproducts, can be created
# with amendments to the string types

#lib/tasks/import.rake
task :csv_model_import, [ :filename, :model ] => [ :environment ] do |task,args|

    asdata = CSV.read(args[:filename], encoding:"cp1252")
    keys = asdata.shift

    if args[:model] == 'Asproduct'
      keys[keys.index "id"] = "sku"
      puts "\nheading name 'id' changed to 'sku'\n"
    else
        if keys.index "id"
            # TODO rename primary_key_field so that id can be used
            # for the time being I'm changing 'id' to 'sku' in the 3dcart table
            puts "you have a field named id, but sql needs that"
            break
        end
    end
    if args[:model] == 'Sasproduct'
        keys = Sasmap.attribute_names[1..-3]
    end

    asdata.each do |values|
        params = {}
        keys.each_with_index do |key,i|
            params[key] = values[i] == nil ? "" : values[i]
        end
        Module.const_get(args[:model]).create(params)
    end
end

task :show_off => :environment do
    Sasproduct.where(:storeid => "1").each { |p| puts p.name }
    Sasproduct.where(:storeid => "2").each { |p| puts p.name }
    puts "How many with :StoreID 1?"
    Sasproduct.where(:storeid => "1").count
    puts "How many with :StoreID 2?"
    Sasproduct.where(:storeid => [1]).count
    puts "How many with either?"
    Sasproduct.where(:storeid => [1..2]).count
end

task :delete_all_storeid_2 => :environment do
    Sasproduct.delete(Sasproduct.where(:storeid => "2").map { |p| p.id })
    # or you can do it this way
    Sasproduct.where(:storeid => "2").delete_all
end

task :sasmap_3dcart => :environment do
    # ok, didn't have as much fun with the database as I would have liked so instead...
    # we're gonna grab the sas header (post modification) from the backup file
    # then parse the JSON to use as keys for the sasmap object

    sash = JSON.parse File.new("./data/sashead.json").readline
    asmap = Sasmap.first

    if File.exists? "./data/exceptions.log"
        FileUtils.rm "./data/exceptions.log"
    end
    outp = "columns:\nnotforsale | stock | sku | name | categories\n"
    puts outp.encode!("cp1252")
    File.open("./data/exceptions.log", "a+:cp1252") { |f| f << "#{outp}\n" }


    include ActionView::Helpers::SanitizeHelper

    # start with the mappings
    asproducts = Asproduct.all
    asproducts.each do |pdata|

      # first weed out the products with no stock - or not for sale
      skipit = false
      if pdata.notforsale == "1" || pdata.stock == "0"
          a = [:notforsale, :stock, :sku, :name, :categories].map { |x| pdata[x] }
          outp = a.join " | "
          if pdata.stock == "0"
              if outp =~ /discontinued/i
                  skipit = true
              else
                  outp += " <==== ### Not excluded from feed. ###"
              end
          end
          if pdata.notforsale == "1"
              skipit = true
          end
          puts outp.encode!("cp1252")
          File.open("./data/exceptions.log", "a+:cp1252") { |f| f << "#{outp}\n" }
          if skipit
              next
          end
      end
      # Ok, lets break it down
      begin
        cats = pdata[:categories].split("@").pop.split("/")
      rescue
        cats = []
      end
      # and build it up again
      params = {}
      asmap.attribute_names[1..-3].each_with_index do |key,i|
        if pdata[asmap[key]] == nil
          pdata[asmap[key]] = asmap[key] # asmap[key] contains default if no mapping
        end

        data = pdata[asmap[key]]

        root = "http://www.arthritissupplies.com"

        case key
        when /status/i
            data = "instock"
        when /description/i
            data = strip_tags(data)
        when /url_to_product/i, /url_to_image/i, /url_to_thumbnail/i, /url_to\w+?/i
            if data.index("/") == 0
                data = root + data
            else
                data = "#{root}/#{data}"
            end
        when /merchantcategory/i
            data = cats[0]
        when /merchantsubcategory/i
            data = cats[1]
        when /merchantgroup/i
            data = cats[2]
        when /merchantsubgroup/i
            data = cats[3]
        when /QuantityDiscount/i
            data = nil
        end

        if data =~ /<\w+?>/
            puts data + " is invalid, possibly\n"
        end
        #puts "#{i}\t|\t#{key}\t|\t#{data}"

        params[key] = data
      end
      Sasproduct.create(params);
    end
end

task :export_sasfeed, [:storeid] => [:environment] do |task,args|
    header = JSON.parse File.read("./data/sasspec.json")
    
    case args[:storeid]
    when "1"
        pdata = Sasproduct.where(:StoreID => "1")
        file = "./data/wsproducts.csv"
    when "2"
        pdata = Asproduct.where(:StoreID => "2")
        file = "./data/asproducts.csv"
    when "3"
        pdata = Cgproduct.where(:StoreID => "3")
        file = "./data/cgproducts.csv"
    when "4"
        pdata = Maproduct.where(:StoreID => "4")
        file = "./data/maproducts.csv"
    end
    fields = pdata.attribute_names[1..-3]
    puts "selected attributes: #{fields}"

    CSV.open(file, "wb:cp1252") do |csv|
        csv << header
        pdata.select(fields).each do |record|
            csv << record.attributes.values
        end
    end
end

    


task :gen_scaffold_args, [ :filename, :model ] => [ :environment ] do |task,args|

  asdata = CSV.read(args[:filename], encoding:"cp1252")
  header = asdata.first

  output = ""
  header.each { |x| output += x+":string " };

  output = "rails generate scaffold #{args[:model]} #{output}"

  outname = "./data/" + args[:model] + "_genscaff.sh"
  File.new(outname, "w").write output

  # if you have a table heading named ID, that will not do.
  # also if you have things with duplicate names, no good at all
  if output =~ /id:string/
    puts "Whoooooa! Id is not ok for a field name!\n"
  end
end

task :gen_sas => :environment do

  sashead = CSV.parse(File.new("./data/shareasale.csv").readline, encoding:"cp1252").shift
  # save a copy of original column names
  sasspec = []
  sashead.each { |val| sasspec.push val }

  sasspec = sasspec.to_json
  Stuff.create(name:"sasspec", data:sasspec)
  File.new("./data/sasspec.json", "w").write sasspec

  # then modify whitespace
  sashead.each_with_index { |val,i| sashead[i] = val.gsub(/ /,"_") }

  # create an instance variable for the header keys
  count = 0
  sashead.map! do |shd|
    if shd == "ReservedForFutureUse"
        shd = "#{shd}#{count+=1}"
    else
        shd
    end
  end
  Stuff.create(name:"sashead", data:sashead.to_json)
  File.new("./data/sashead.json","w").write sashead.to_json

  first, *rest = *sashead
  outStr = "#{first}:string"
  rest.each { |shd| outStr += " #{shd}:string" }

  outStr = "rails generate scaffold Sasmap #{outStr}"
  File.new("./data/Sasmap_genscaf.sh", "w").write outStr

  # adjust the field types for larger strings
  outStr = "#{first}:string"
  rest.each do |shd|
    case shd
    when "Description", "SearchTerms"
      type = ":text"
    else
      type = ":string"
    end
    outStr += " #{shd}#{type}"
  end

  outStr = "rails generate scaffold Sasproduct #{outStr}"
  File.new("./data/Sasproduct_genscaf.sh", "w").write outStr

  puts "\nDon't forget to double check your string limits.\n"
  puts "However, Sasmap_genscaf.sh should be all string types\n"
  puts "and Sasproduct_genscaf.sh should have 2 fields altered for text.\n"
end

task :gen_3dcart_model => :environment do
  ashead = CSV.parse(File.new("./data/AS-latest.csv").readline, encoding:"cp1252").shift
  # save a copy of original column names
  asspec = []
  ashead.each { |val| asspec.push val }

  asspec = asspec.to_json
  Stuff.create(name:"asspec", data:asspec)
  File.new("./data/asspec.json", "w").write asspec

  # then modify whitespace
  ashead.each_with_index { |val,i| ashead[i] = val.gsub(/ /,"_") }

  # then fixup the header keys
  ashead.map! do |shd|
    if shd == "id"
        # Watchout!!! ashead gets assigned the last returned value
        puts "Changing id to sku!\n"
        # So you MUST have 'shd = ...' here or things will not be as you think
        shd = "sku"
    else
        shd
    end
  end

  # and dump it to file for later
  asout = ashead.to_json
  Stuff.create(name:"ashead", data:asout)
  File.new("./data/ashead.json","w").write asout

  # now to generate the rails generate command string generator
  first, *rest = *ashead
  outStr = "#{first}:string"
  rest.each do |shd|
    case shd
    when "extended_description", "keywords"
      type = ":text"
    else
      type = ":string"
    end
    outStr += " #{shd}#{type}"
  end

  outStr = "rails generate scaffold Asproduct #{outStr}"
  File.new("./data/Asproduct_genscaf.sh", "w").write outStr

  puts "\nDon't forget to double check your string limits.\n"
  puts "Asproduct_genscaf.sh should have 2 fields changed to :text.\n"
end


