class StuffsController < ApplicationController
  # GET /stuffs
  # GET /stuffs.json
  def index
    @stuffs = Stuff.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @stuffs }
    end
  end

  # GET /stuffs/1
  # GET /stuffs/1.json
  def show
    @stuff = Stuff.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @stuff }
    end
  end

  # GET /stuffs/new
  # GET /stuffs/new.json
  def new
    @stuff = Stuff.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @stuff }
    end
  end

  # GET /stuffs/1/edit
  def edit
    @stuff = Stuff.find(params[:id])
  end

  # POST /stuffs
  # POST /stuffs.json
  def create
    @stuff = Stuff.new(params[:stuff])

    respond_to do |format|
      if @stuff.save
        format.html { redirect_to @stuff, notice: 'Stuff was successfully created.' }
        format.json { render json: @stuff, status: :created, location: @stuff }
      else
        format.html { render action: "new" }
        format.json { render json: @stuff.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /stuffs/1
  # PUT /stuffs/1.json
  def update
    @stuff = Stuff.find(params[:id])

    respond_to do |format|
      if @stuff.update_attributes(params[:stuff])
        format.html { redirect_to @stuff, notice: 'Stuff was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @stuff.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stuffs/1
  # DELETE /stuffs/1.json
  def destroy
    @stuff = Stuff.find(params[:id])
    @stuff.destroy

    respond_to do |format|
      format.html { redirect_to stuffs_url }
      format.json { head :no_content }
    end
  end
end
