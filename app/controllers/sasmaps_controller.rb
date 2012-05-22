class SasmapsController < ApplicationController
  # GET /sasmaps
  # GET /sasmaps.json
  def index
    @sasmaps = Sasmap.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sasmaps }
    end
  end

  # GET /sasmaps/1
  # GET /sasmaps/1.json
  def show
    @sasmap = Sasmap.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sasmap }
    end
  end

  # GET /sasmaps/new
  # GET /sasmaps/new.json
  def new
    @sasmap = Sasmap.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sasmap }
    end
  end

  # GET /sasmaps/1/edit
  def edit
    @sasmap = Sasmap.find(params[:id])
  end

  # POST /sasmaps
  # POST /sasmaps.json
  def create
    @sasmap = Sasmap.new(params[:sasmap])

    respond_to do |format|
      if @sasmap.save
        format.html { redirect_to @sasmap, notice: 'Sasmap was successfully created.' }
        format.json { render json: @sasmap, status: :created, location: @sasmap }
      else
        format.html { render action: "new" }
        format.json { render json: @sasmap.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sasmaps/1
  # PUT /sasmaps/1.json
  def update
    @sasmap = Sasmap.find(params[:id])

    respond_to do |format|
      if @sasmap.update_attributes(params[:sasmap])
        format.html { redirect_to @sasmap, notice: 'Sasmap was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @sasmap.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sasmaps/1
  # DELETE /sasmaps/1.json
  def destroy
    @sasmap = Sasmap.find(params[:id])
    @sasmap.destroy

    respond_to do |format|
      format.html { redirect_to sasmaps_url }
      format.json { head :no_content }
    end
  end
end
