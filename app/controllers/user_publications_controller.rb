class UserPublicationsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_user_publication, only: [
    :show, :edit, :update, :destroy, :request_full_text, :download_document
  ]
  before_action :get_publication_permission, only: [:approve_request, :deny_request]
  before_action :mark_notification_as_read, only: [:approve_request, :deny_request]

  def index
    @user_publications = UserPublication.all
  end

  def show; end

  def new
    @user_publication = UserPublication.new
  end

  def edit; end

  def create
    @user_publication = UserPublication.new(sanitized_params.except(:authors).merge(user_id: current_user.id))
    check_publication_date_format
    user_pub_save = @user_publication.save

    @geotagged = params["geotag"] == "on"
    @publications = Hash.new

    if user_pub_save
      @publications = UserPublication.where(user_id: current_user.id).order("created_at DESC")
      NotificationWorker.perform_async(current_user.id, "<b>#{current_user.name.to_s}</b> has added a new publication titled <b>#{@user_publication.title}</b>.")
    end

    respond_to do |format|
      if user_pub_save
        Activity.create!(
          activity: "Added a publication **[#{@user_publication.title}](#{user_publication_path(@user_publication)})**",
          user: current_user
        )

        format.html { redirect_to @user_publication, notice: 'User publication was successfully created.' }
        format.json { render :show, status: :created, location: @user_publication }
        format.js
      else
        format.html { render :new }
        format.json { render json: @user_publication.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def update
    respond_to do |format|
      @user_publication.assign_attributes(sanitized_params.except(:authors))
      check_publication_date_format
      if @user_publication.save
        Activity.create!(
          activity: "Updated a publication **[#{@user_publication.title}](#{user_publication_path(@user_publication)})**",
          user: current_user
        )

        format.html { redirect_to @user_publication, notice: 'User publication was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_publication }
        format.js
      else
        format.html { render :edit }
        format.json { render json: @user_publication.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def request_full_text
    request = @user_publication.find_or_create_permission_request_for(current_user)
    if !request.approved?
      request.notify_requested!
    end
  end

  def download_document
    paper = @user_publication.paper
    return unless paper.file?

    return if paper.content_type == 'application/pdf'

    document_data = open(paper.url)

    send_data(
      document_data.read,
      filename: paper.original_filename,
      type: paper.content_type,
      deposition: 'inline'
    )
  end

  def approve_request
    if @user_publication_permission.may_approve?
      @user_publication_permission.approve!
      @message = {
        type: :notice,
        message: "You have approved #{@user_publication_permission.requester&.name} to access the full text for #{@user_publication_permission.user_publication.title}"
      }

      @notifications = Notification.where(user_id: current_user.id).order(created_at: :desc)
      @notifications_unread = @notifications.where(read: false).count
    else
      @message = { type: :alert, message: 'Could not approve this request' }
    end
  end

  def deny_request
    if @user_publication_permission.may_deny?
      @user_publication_permission.deny!
      @message = {
        type: :notice,
        message: "You have denied #{@user_publication_permission.requester&.name} to access the full text for #{@user_publication_permission.user_publication.title}"
      }

      @notifications = Notification.where(user_id: current_user.id).order(created_at: :desc)
      @notifications_unread = @notifications.where(read: false).count
    else
      @mesage = { type: :alert, message: 'Could not denied this request' }
    end
  end

  def destroy
    user_id = @user_publication.user_id
    @user_publication.destroy

    redirect_to user_path(user_id), notice: "Publication was deleted"
  end

  private

  def set_user_publication
    @user_publication = UserPublication.friendly.find(params[:id])
  end

  def get_publication_permission
    @user_publication_permission = UserPublicationPermission.find(params[:user_publication_perprogram_id])
  end

  def sanitized_params
    @sanitized_params ||= user_publication_params.merge!(
      tag_ids: handle_tag_params(user_publication_params[:tag_ids]),
      keep_private: user_publication_params[:keep_private].to_i.to_b,
      author_ids: get_author_ids_from(user_publication_params[:authors]),
      additional_authors: get_string_author_from(user_publication_params[:authors])
    )
  end

  def user_publication_params
    @publication_params ||= params.require(:user_publication).permit(
      :user_id, :summary, :title, :paper, :publisher,
      :abstract, :doi, :publication_date, :publication_url,
      :volume, :issue, :arXiv, :PMID, :keep_private,
      :tag_ids, :authors, :is_clear_paper_file,
      publication_long_lats_attributes: [
        :id, :longitude, :latitude, :max_long, :max_lat,
        :planet,  :_destroy
      ]
    )
  end

  def mark_notification_as_read
    notification = Notification.find_by(
      user: current_user,
      notifiable: @user_publication_permission
    )
    notification.read! if notification
  end

  def check_publication_date_format
    date = sanitized_params[:publication_date]
    unless date.match?(/\A\d{4}\-(0?[1-9]|1[012])(|\-(0?[1-9]|[12][0-9]|3[01]))\z/)
      @user_publication.errors.add(:publication_date, 'must be in format YYYY-MM-DD or YYYY-MM')
    end
  end

  def get_author_ids_from(author_list)
    return [] unless author_list

    return @author_ids if @author_ids.present?

    @author_ids = author_list.split(',').map do |item|
      next unless int?(item)

      item
    end.compact
  end

  def get_string_author_from(author_list)
    return [] unless author_list

    return @authors_string if @authors_string.present?

    @authors_string = author_list.split(',').map do |item|
      next if int?(item)

      item
    end.compact
  end
end
