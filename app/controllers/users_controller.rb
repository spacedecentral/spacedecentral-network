class UsersController < ApplicationController
  # TEMP
  # before_action :authenticate_user!, except: [
  #   :show, :index, :load_more_activities
  # ]
  # TEMP
  before_action :authenticate_user!, except: [:index]
  before_action :set_user, only: [
    :show, :edit, :update, :destroy, :add_skills, :load_more_activities,
    :edit_user_education, :update_user_education
  ]
  before_action :set_cache_headers, only: [:show]

  # GET /users
  def index
    @users = User.all.order(:name)
  end

  def search
    if params[:term]
      @users = User.where("name LIKE ?", "%#{params[:term]}%")
    else
      redirect_to people_path
    end

    respond_to do |format|
      format.html
      format.json
    end
  end

  # GET /users/1
  def show
    @editable_by_user = !current_user.nil? && current_user.id == @user.id
    @programs = Program.program_type.joins(:program_user_roles).where('program_user_roles.user_id = ?', @user.id)
    @publications = UserPublication.where(:user_id=>@user.id).order("user_publications.created_at DESC")
    @user_activities = @user.activities.order(created_at: :desc).page(params[:page]).per(15)
    load_more_activities
  end

  def load_more_activities
    @user_activities = @user.activities.order(created_at: :desc).page(params[:page]).per(15)
  end

  # GET /users/1/edit
  def edit
    @is_admin_user = current_user&.is_admin_user?
  end

  # PATCH/PUT /users/1
  def update
    respond_to do |format|
      @user.assign_attributes(sanitized_params)
      if @user.save(context: :update_profile)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :created, location: @user }
        format.js   { render :layout => false }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
        format.js   { render :layout => false, status: 500 }
      end
    end
  end

  def edit_user_education
    @user.user_educations || @user.user_educations.build
  end

  def update_user_education
    unless @user.update(sanitized_params)
      error_educations = @user.user_educations.select {|education| education.id.nil? }
      @user_educations = error_educations + @user.user_educations.select{|education| education.id.present?}
    end
  end

  def settings; end

  def edit_settings; end

  def update_settings
    return unless params[:step].present?

    respond_to do |format|
      if public_send("update_#{params[:step]}")
        format.js
      else
        format.js { render status: 500 }
      end
    end
  end

  def update_personal
    current_user.assign_attributes(update_personal_params)
    current_user.save(context: :update_personal)
  end

  def update_username
    current_user.assign_attributes(update_username_params)
    current_user.save(context: :update_username)
  end

  def update_email
    current_user.assign_attributes(update_email_params)
    current_user.save(context: :update_email)
  end

  def update_newsletter
    current_user.assign_attributes(update_newsletter_params)
    current_user.save(context: :update_newsletter)
  end

  def update_notifications
    current_user.assign_attributes(update_notifications_params)
    current_user.save(context: :update_notifications)
  end

  def update_password
    current_user.assign_attributes(update_password_params)
    if current_user.save(context: :update_password)
      bypass_sign_in(current_user)
      true
    end
  end

  def generate_new_password_email
    current_user.send_reset_password_instructions
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.friendly.find(params[:id])
    end

    def sanitized_params
      @sanitized_params ||= user_params.merge!(
        skill_ids: handle_tag_params(user_params[:skill_ids])
      )
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(
        :name, :avatar, :cover_photo, :bio, :role, :cover_dy, :title, :location,
        :remove_avatar, :remove_cover_photo, :skill_ids, :linkedin_url,
        user_careers_attributes: [
          :id, :position, :company, :from, :to,  :_destroy
        ],
        user_educations_attributes: [
          :id, :degree, :school, :graduation, :_destroy
        ]
      )
    end

    def update_personal_params
      params.require(:user).permit(:name, :title, :location, :avatar, :remove_avatar)
    end

    def update_username_params
      params.require(:user).permit(:username)
    end

    def update_email_params
      params.require(:user).permit(:email, :email_confirmation, :current_password)
    end

    def update_password_params
      params.require(:user).permit(:current_password, :new_password, :new_password_confirmation)
    end

    def update_newsletter_params
      params.require(:user).permit(:newsletter)
    end

    def update_notifications_params
      params.require(:user).permit(:notifications)
    end

    def set_cache_headers
      response.headers["Cache-Control"] = "no-cache, no-store"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    end
end
