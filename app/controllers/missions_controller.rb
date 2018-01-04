class MissionsController < ApplicationController
  layout :resolve_layout, except: [:new]
  # TEMP
  # before_action :authenticate_user!, except: [:show, :index, :tab_render_control]
  # TEMP
  before_action :authenticate_user!, only: [:new,:create,:edit,:update,:destroy]
  before_action :set_mission, only: [:show, :edit, :update, :destroy, :tab_render_control]

  require 'google/apis/drive_v2'
  require 'google/api_client/client_secrets'

  def index
    @missions = Mission.mission_type
    @is_admin_user = current_user&.is_admin_user?
  end

  def search
    term = params["term"]
    if !term.nil?
      @missions = Mission.mission_type.where("name LIKE ?", "%"+term+"%", )
    else
      redirect_to missions_path
    end

    respond_to do |format|
      format.html
      format.json
    end
  end

  def tab_render_control
    @selector = params["selector"]
    @missionfiles = {:items=>[]}
    if @selector == "main_mission_tab"
      # @missionfiles = GDriveFile.where(:mission_id=>@mission.id).order("created_at DESC").limit(5)
      begin
        drive = Google::Apis::DriveV2::DriveService.new
        auth_client = auth_svcacc_gdrive
        drive.authorization = auth_client
        @missionfiles = drive.list_files(q: "'#{@mission.gdrive_folder_id}' in parents", max_results: 7, order_by: 'modifiedDate desc', fields: "items(modifiedDate,iconLink,alternateLink,title,id),next_page_token,self_link", options: { authorization: auth_client })
        @missionfiles = @missionfiles.to_h
      rescue Exception => e
        Rails.logger.info e.inspect
      end
    elsif @selector == 'mission_crews'
      @role_filter_name = "all"
      if !params[:mission_crew_keyword]&.empty?
        @members = @members.joins(:user).where('users.name LIKE ?', "%#{params[:mission_crew_keyword]}%")
      end
      if !params[:role].nil? && params[:role] != 'all'
        param_role = params[:role].to_i
        @members = @members.select {|m| m.role == param_role }
        @role_filter_name = MissionUserRole::MISSION_ROLE_NAMES[param_role][:name].try(:downcase) || "all"
      end
    elsif @selector == "planning_mission_tab"
    elsif @selector == "mission_files"
      @gdrive_authenticated = session.has_key?(:credentials)
      get_svcacc_gfiles(params)
      # @missionfiles = GDriveFile.where(:mission_id=>@mission.id)
    elsif @selector == 'mission_discussions'
      @posts = Filter::PostFilter.new({ mission_ids: [@mission.id] }).call
      @tags = Tag.joins(:posts).where(posts: { id: @posts.pluck(:id) }).distinct
      params[:filter] = { mission_ids: [@mission.id], category: Filter::PostFilter::RECENT }
    end
  end

  def show
    @main_mission_show_url = true
    @missionchat = Message.where(:mission_id=>@mission.id)
    @posts = Filter::PostFilter.call({ category: 'recent', mission_ids: [@mission.id] }, 1, 2)
    # @missionfiles = GDriveFile.where(:mission_id=>@mission.id).order("created_at DESC").limit(5)
    @missionfiles = {:items=>[]}
    begin
      drive = Google::Apis::DriveV2::DriveService.new
      auth_client = auth_svcacc_gdrive
      drive.authorization = auth_client
      # @missionfiles = GDriveFile.where(:mission_id=>@mission.id).order("created_at DESC").limit(5)
      @missionfiles = drive.list_files(q: "'#{@mission.gdrive_folder_id}' in parents", max_results: 5, order_by: 'modifiedDate desc', fields: "items(modifiedDate,iconLink,alternateLink,title,id),next_page_token,self_link", options: { authorization: auth_client })
      @missionfiles = @missionfiles.to_h
    rescue Exception => e
      Rails.logger.info e.inspect
    end
  end

  def new
    @mission = Mission.new

    if params[:object_type].present?
      @mission.object_type = params[:object_type].to_i
    end
    if params[:parent].present?
      @mission.parent = params[:parent]
    end
  end

  def edit; end

  def create
    extra_mission_params = Hash.new

    @mission = Mission.new(mission_params.merge(extra_mission_params))
    mission_save = @mission.save

    if mission_save
      begin
        drive = Google::Apis::DriveV2::DriveService.new
        drive.authorization = auth_svcacc_gdrive
        folder_name = mission_params['name']
        if Rails.env.staging?
          folder_name += "_staging"
        elsif Rails.env.development?
          folder_name += "_dev"
        end
        drive_file = drive.insert_file({title:folder_name,mime_type:"application/vnd.google-apps.folder"})
        extra_mission_params['gdrive_folder_id'] = drive_file.to_h[:id]
      rescue Exception => e
        Rails.logger.info e.inspect
      end

      begin
        mu = MissionUserRole.new
        mu.user_id = current_user.id
        mu.mission_id = @mission.id
        mu.role = current_user.role
        mu.pending = false
        mu.save
      rescue Exception => e
        Rails.logger.info e.inspect
      end
    end
    respond_to do |format|
      if mission_save
        Activity.create!(
          activity: "Create a new #{@mission.object_type} **[#{@mission.name}](#{mission_path(@mission)})**",
          user: current_user,
        )

        format.html {
          notice = if @mission.mission_type?
                    'Mission was successfully created.'
                   else
                    'Project was successfully added.'
                   end
          redirect_to @mission, notice: notice
        }
        format.json { render :show, status: :created, location: @mission }
        format.js
      else
        format.html { render :new }
        format.json { render json: @mission.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def update
    respond_to do |format|
      if @mission.update(mission_params)
        Activity.create!(
          activity: "Updated a #{@mission.object_type} **[#{@mission.name}](#{mission_path(@mission)})**",
          user: current_user
        )
        format.html {
          notice = if @mission.mission_type?
                    'Mission was successfully updated.'
                   else
                    'Project was successfully updated.'
                   end
          redirect_to @mission, notice: notice
        }
        format.json { render :show, status: :ok, location: @mission }
        format.js
      else
        format.html { render :edit }
        format.json { render json: @mission.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def destroy
    deleted_mission = @mission
    if @mission.destroy
      Activity.create!(
        activity: "Deleted a #{@mission.object_type} **#{deleted_mission.name}**",
        user: current_user,
      )
    end
    respond_to do |format|
      format.html { redirect_to missions_url, notice: "#{deleted_mission.object_type.humanize} was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def auth_svcacc_gdrive
      scope = ['https://www.googleapis.com/auth/drive']

      ENV["GOOGLE_APPLICATION_CREDENTIALS"] = Rails.root.join('spacedecentral-creds.json').to_s
      authorization = Google::Auth.get_application_default(scope)

      auth_client = authorization.dup
      auth_client.sub = 'gsuite@space.coop'
      auth_client.fetch_access_token!
      return auth_client
    end

    def get_svcacc_gfiles(params)
      sva_drive = Google::Apis::DriveV2::DriveService.new
      auth_client = auth_svcacc_gdrive
      sva_drive.authorization = auth_client
      sort_by = "modifiedDate "
      if !params['sort_by'].nil?
        sort_by = params['sort_by']
      end
      if params['sort_dir'] != "1"
        sort_by += " desc"
      end
      Rails.logger.info sort_by.inspect
      if !params["mission_file_search_term"].nil?
        @mission_file_search_term = params["mission_file_search_term"]
        if @mission_file_page.nil?
          @missionfiles = sva_drive.list_files(q: "'#{@mission.gdrive_folder_id}' in parents and title contains '#{@mission_file_search_term}'", max_results: 20, order_by: sort_by, fields: "items(modifiedDate,iconLink,alternateLink,title,id),next_page_token,self_link", options: { authorization: auth_client })
        else
          @missionfiles = sva_drive.list_files(q: "'#{@mission.gdrive_folder_id}' in parents and title contains '#{@mission_file_search_term}'", max_results: 20, page_token: @mission_file_page, order_by: sort_by, fields: "items(modifiedDate,iconLink,alternateLink,title,id),next_page_token,self_link", options: { authorization: auth_client })
        end
      else
        if @mission_file_page.nil?
          @missionfiles = sva_drive.list_files(q: "'#{@mission.gdrive_folder_id}' in parents", max_results: 20, page_token: @mission_file_page, order_by: sort_by, fields: "items(modifiedDate,iconLink,alternateLink,title,id),next_page_token,self_link", options: { authorization: auth_client })
        else
          @missionfiles = sva_drive.list_files(q: "'#{@mission.gdrive_folder_id}' in parents", max_results: 20, page_token: @mission_file_page, order_by: sort_by, fields: "items(modifiedDate,iconLink,alternateLink,title,id),next_page_token,self_link", options: { authorization: auth_client })
        end
      end
      @missionfiles = @missionfiles.to_h
      @mission_file_next_page = @missionfiles[:next_page_token]
      @mission_file_page = [:self_link]
      @params = params
    end

    def set_mission
      @mission = Mission.friendly.find(params[:id])
      @members = MissionUserRole.where(mission_id: @mission.id)
      @isMember = false
      if !current_user.nil?
        @current_member_role = @members.where(user_id: current_user.id)
        if !@current_member_role.empty?
          @isMember = true
          @current_member_role = @current_member_role.first
        else
          @current_member_role = nil
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mission_params
      params.require(:mission).permit(
        :name, :gdrive_folder_id, :description, :objectives,
        :cover, :cover_dy, :remove_cover, :object_type, :parent
      )
    end

    def resolve_layout
      case action_name
      when "index"
        "application"
      else
        "mission"
      end
    end
end
