class TagReferencesController < ApplicationController
  before_action :set_tag_reference, only: [:show, :edit, :update, :destroy]
  before_action :set_all_tag_references, only: [:create,:destroy,:new]

  skip_before_filter :set_messages
  skip_before_filter :set_notifications
  skip_before_filter :set_global_user

  # GET /tag_references
  # GET /tag_references.json
  def index
    @tag_references = TagReference.all
  end

  # GET /tag_references/1
  # GET /tag_references/1.json
  def show
  end

  # GET /tag_references/new
  def new
    @tag_reference = TagReference.new
    @tag_ref_name = params['tag_ref_name']
    if !params['user_publication_id'].nil?
      @tag_reference.user_publication_id = params['user_publication_id']
    elsif !params['post_id'].nil?
      @tag_reference.post_id = params['post_id']
    elsif !params['user_id'].nil?
      @tag_reference.user_id = params['user_id']
    end
  end

  # GET /tag_references/1/edit
  def edit
  end

  # POST /tag_references
  # POST /tag_references.json
  def create
    @tag_reference_save = TagReference.new(tag_reference_params)
    if tag_reference_params['tag_id'].empty?
      begin
        tag = Tag.new
        tag.tag = params['tag_lookup_text']
        tag.save
        @tag_reference_save.tag_id = tag.id
      rescue Exception=> e
        Rails.logger.info e.inpect
        @tag_reference_save.errors.add(:tag_id, e.message)
      end
    end

    new_tag_ref_save = @tag_reference_save.save

    if new_tag_ref_save
      if request.xhr?
        @tag_reference = TagReference.new
        if !@tag_reference_save.user_publication_id.nil?
          @tag_reference.user_publication_id = @tag_reference_save.user_publication_id
        elsif !@tag_reference_save.post_id.nil?
          @tag_reference.post_id = @tag_reference_save.post_id
        elsif !@tag_reference_save.user_id.nil?
          @tag_reference.user_id = @tag_reference_save.user_id
        end
      end
    end
    @tag_ref_name = params['tag_ref_name']

    respond_to do |format|
      if new_tag_ref_save
        format.html { redirect_to @tag_reference_save, notice: 'Tag was successfully created.' }
        format.json { render :show, status: :created, location: @tag_reference_save }
        format.js   { render :layout => false }
      else
        format.html { render :new }
        format.json { render json: @tag_reference_save.errors, status: :unprocessable_entity }
        format.js   { render :layout => false, status: 500 }
      end
    end
  end

  # PATCH/PUT /tag_references/1
  # PATCH/PUT /tag_references/1.json
  def update
    respond_to do |format|
      if @tag_reference.update(tag_reference_params)
        format.html { redirect_to @tag_reference, notice: 'Tag reference was successfully updated.' }
        format.json { render :show, status: :ok, location: @tag_reference }
      else
        format.html { render :edit }
        format.json { render json: @tag_reference.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tag_references/1
  # DELETE /tag_references/1.json
  def destroy
    @tag_reference.destroy
    respond_to do |format|
      format.html { redirect_to tag_references_url, notice: 'Tag reference was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tag_reference
      @tag_reference = TagReference.find(params[:id])
    end

    def set_all_tag_references
      #TODO find current tags based on what object is used
      if !params['user_publication_id'].nil?
        @current_tags = TagReference.where(:user_publication_id => params['user_publication_id'])
      elsif !params['post_id'].nil?
        @current_tags = TagReference.where(:post_id => params['post_id'])
      elsif !params['user_id'].nil?
        @current_tags = TagReference.where(:user_id => params['user_id'])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tag_reference_params
      params.require(:tag_reference).permit(:tag_id,:user_publication_id,:post_id,:user_id)
    end
end
