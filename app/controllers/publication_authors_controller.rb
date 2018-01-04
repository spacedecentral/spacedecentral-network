class PublicationAuthorsController < ApplicationController
  before_action :set_publication_author, only: [:show, :edit, :update, :destroy]

  skip_before_filter :set_messages
  skip_before_filter :set_notifications
  skip_before_filter :set_global_user
  
  # GET /publication_authors
  # GET /publication_authors.json
  def index
    @publication_authors = PublicationAuthor.all
  end

  # GET /publication_authors/1
  # GET /publication_authors/1.json
  def show
  end

  # GET /publication_authors/new
  def new
    @publication_author = PublicationAuthor.new
  end

  # GET /publication_authors/1/edit
  def edit
  end

  # POST /publication_authors
  # POST /publication_authors.json
  def create
    @publication_author = PublicationAuthor.new(publication_author_params)

    respond_to do |format|
      if @publication_author.save
        format.html { redirect_to @publication_author, notice: 'Publication author was successfully created.' }
        format.json { render :show, status: :created, location: @publication_author }
      else
        format.html { render :new }
        format.json { render json: @publication_author.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /publication_authors/1
  # PATCH/PUT /publication_authors/1.json
  def update
    respond_to do |format|
      if @publication_author.update(publication_author_params)
        format.html { redirect_to @publication_author, notice: 'Publication author was successfully updated.' }
        format.json { render :show, status: :ok, location: @publication_author }
      else
        format.html { render :edit }
        format.json { render json: @publication_author.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /publication_authors/1
  # DELETE /publication_authors/1.json
  def destroy
    @publication_author.destroy
    respond_to do |format|
      format.html { redirect_to publication_authors_url, notice: 'Publication author was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_publication_author
      @publication_author = PublicationAuthor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def publication_author_params
      params.fetch(:publication_author, {})
    end
end
