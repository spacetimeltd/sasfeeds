class SasproductsController < ApplicationController
  # GET /sasproducts
  # GET /sasproducts.json
  def index
    @sasproducts = Sasproduct.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sasproducts }
    end
  end

  # GET /sasproducts/1
  # GET /sasproducts/1.json
  def show
    @sasproduct = Sasproduct.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sasproduct }
    end
  end

  # GET /sasproducts/new
  # GET /sasproducts/new.json
  def new
    @sasproduct = Sasproduct.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sasproduct }
    end
  end

  # GET /sasproducts/1/edit
  def edit
    @sasproduct = Sasproduct.find(params[:id])
  end

  # POST /sasproducts
  # POST /sasproducts.json
  def create
    @sasproduct = Sasproduct.new(params[:sasproduct])

    respond_to do |format|
      if @sasproduct.save
        format.html { redirect_to @sasproduct, notice: 'Sasproduct was successfully created.' }
        format.json { render json: @sasproduct, status: :created, location: @sasproduct }
      else
        format.html { render action: "new" }
        format.json { render json: @sasproduct.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sasproducts/1
  # PUT /sasproducts/1.json
  def update
    @sasproduct = Sasproduct.find(params[:id])

    respond_to do |format|
      if @sasproduct.update_attributes(params[:sasproduct])
        format.html { redirect_to @sasproduct, notice: 'Sasproduct was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @sasproduct.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sasproducts/1
  # DELETE /sasproducts/1.json
  def destroy
    @sasproduct = Sasproduct.find(params[:id])
    @sasproduct.destroy

    respond_to do |format|
      format.html { redirect_to sasproducts_url }
      format.json { head :no_content }
    end
  end
end
