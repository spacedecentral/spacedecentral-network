class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy, :toggle_pin]
  before_action :authenticate_user!, only: [:new,:create,:edit,:update,:destroy,:toggle_pin]

  def index
    filter
    @programs = Program.program_type
    @tags = Tag.joins(:posts).distinct
  end

  def filter
    if params[:filter].blank? || (params[:filter] &&  params[:filter][:category].blank?)
      params[:filter] = { category: Filter::PostFilter::RECENT }
    end

    @filter_params = filter_params
    @posts = ::Filter::PostFilter.new(filter_params, params[:page]).call
  end

  def index_program
    @posts = Post.joins(:tag_references).where(tag_references: { program_id: params[:program_id] })
    @programs = Program.all
    @tags = Tag.all
    @current_program = Program.find (params[:program_id])
  end

  def index_tag
    @posts = Post.joins("inner join tag_references on posts.id = tag_references.post_id where tag_id = ", params[:tag_id])
    @programs = Program.all
    @tags = Tag.all
    @current_tag = Tag.find (params[:tag_id])
  end

  def show; end

  def new
    @post = Post.new
    @tags = Tag.order('created_at DESC')
  end

  def edit; end

  def create
    @post = current_user.posts.build(sanitized_params)

    respond_to do |format|
      if @post.save
        Activity.create!(
          activity: "Created new post **[#{@post.title}](#{post_path(@post)})**",
          user: current_user
        )

        # by default create a watcher
        Watcher.create!(
          watchable_type: @post.class.name,
          watchable_id: @post.id,
          user: current_user
        )

        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
        format.js
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
        format.js { render status: 500 }
      end
    end
  end

  def update
    respond_to do |format|
      if @post.update(sanitized_params)
        Activity.create!(
          activity: "Updated a post **[#{@post.title}](#{post_path(@post)})**",
          user: current_user
        )

        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
        format.js
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
        format.js { render status: 500 }
      end
    end
  end

  def destroy
    @deleted_post = @post
    @post.destroy

    respond_to do |format|
      format.html {
        redirect_to posts_url, notice: 'Post was deleted.'
      }
      format.json { head :no_content }
      format.js
    end
  end

  def toggle_pin
      @post.toggle!(:pinned)
      filter

      respond_to do |format|
        format.js
      end
  end

  private

  def set_post
    @post = Post.friendly.find(params[:id])
  end

  def sanitized_params
    post_params.merge!(
      tag_ids: handle_tag_params(post_params[:tag_ids])
    )
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def post_params
    params.require(:post).permit(:title, :content, :tag_ids, :postable_type, :postable_id)
  end

  def filter_params
    params.require(:filter).permit(
      :keyword,
      :category,
      program_ids: [],
      tag_ids: []
    ) rescue {}
  end
end
