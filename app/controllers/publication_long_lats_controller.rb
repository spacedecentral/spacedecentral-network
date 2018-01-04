class PublicationLongLatsController < ApplicationController
  before_action :set_publication_long_lat, only: [:show, :edit, :update, :destroy]


  skip_before_filter :set_messages
  skip_before_filter :set_notifications
  skip_before_filter :set_global_user
  
  # GET /publication_long_lats
  # GET /publication_long_lats.json
  def index
    @publication_long_lats = PublicationLongLat.all
  end

  # GET /publication_long_lats/1
  # GET /publication_long_lats/1.json
  def show
  end

  # GET /publication_long_lats/new
  def new
    @publication_long_lat = PublicationLongLat.new
  end

  # GET /publication_long_lats/1/edit
  def edit
  end

  # POST /publication_long_lats
  # POST /publication_long_lats.json
  def create
    @publication_long_lat = PublicationLongLat.new(publication_long_lat_params)

    respond_to do |format|
      if @publication_long_lat.save
        format.html { redirect_to @publication_long_lat, notice: 'Publication long lat was successfully created.' }
        format.json { render :show, status: :created, location: @publication_long_lat }
      else
        format.html { render :new }
        format.json { render json: @publication_long_lat.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /publication_long_lats/1
  # PATCH/PUT /publication_long_lats/1.json
  def update
    respond_to do |format|
      if @publication_long_lat.update(publication_long_lat_params)
        format.html { redirect_to @publication_long_lat, notice: 'Publication long lat was successfully updated.' }
        format.json { render :show, status: :ok, location: @publication_long_lat }
      else
        format.html { render :edit }
        format.json { render json: @publication_long_lat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /publication_long_lats/1
  # DELETE /publication_long_lats/1.json
  def destroy
    @publication_long_lat.destroy
    respond_to do |format|
      format.html { redirect_to publication_long_lats_url, notice: 'Publication long lat was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_publication_long_lat
      @publication_long_lat = PublicationLongLat.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def publication_long_lat_params
      params.fetch(:publication_long_lat, {})
    end
end
