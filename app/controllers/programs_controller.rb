class ProgramsController < ApplicationController
  layout :resolve_layout, except: [:new]
  # TEMP
  # before_action :authenticate_user!, except: [:show, :index, :tab_render_control]
  # TEMP
  before_action :authenticate_user!, only: [:new,:create,:edit,:update,:destroy]
  before_action :set_program, only: [:show, :edit, :update, :destroy, :tab_render_control]

  require 'google/apis/drive_v2'
  require 'google/api_client/client_secrets'

  def index
    @programs = Program.program_type
    @is_admin_user = current_user&.is_admin_user?
  end

  def search
    term = params["term"]
    if !term.nil?
      @programs = Program.program_type.where("name LIKE ?", "%"+term+"%", )
    else
      redirect_to programs_path
    end

    respond_to do |format|
      format.html
      format.json
    end
  end

  def tab_render_control
    @selector = params["selector"]
    @programfiles = {:items=>[]}
    if @selector == "main_program_tab"
      # @programfiles = GDriveFile.where(:program_id=>@program.id).order("created_at DESC").limit(5)
      begin
        drive = Google::Apis::DriveV2::DriveService.new
        auth_client = auth_svcacc_gdrive
        drive.authorization = auth_client
        @programfiles = drive.list_files(q: "'#{@program.gdrive_folder_id}' in parents", max_results: 7, order_by: 'modifiedDate desc', fields: "items(modifiedDate,iconLink,alternateLink,title,id),next_page_token,self_link", options: { authorization: auth_client })
        @programfiles = @programfiles.to_h
      rescue Exception => e
        Rails.logger.info e.inspect
      end
    elsif @selector == 'program_crews'
      @role_filter_name = "all"
      if !params[:program_crew_keyword]&.empty?
        @members = @members.joins(:user).where('users.name LIKE ?', "%#{params[:program_crew_keyword]}%")
      end
      if !params[:role].nil? && params[:role] != 'all'
        param_role = params[:role].to_i
        @members = @members.select {|m| m.role == param_role }
        @role_filter_name = ProgramUserRole::MISSION_ROLE_NAMES[param_role][:name].try(:downcase) || "all"
      end
    elsif @selector == "planning_program_tab"
    elsif @selector == "program_files"
      @gdrive_authenticated = session.has_key?(:credentials)
      get_svcacc_gfiles(params)
      # @programfiles = GDriveFile.where(:program_id=>@program.id)
    elsif @selector == 'program_discussions'
      @posts = Filter::PostFilter.new({ program_ids: [@program.id] }).call
      @tags = Tag.joins(:posts).where(posts: { id: @posts.pluck(:id) }).distinct
      params[:filter] = { program_ids: [@program.id], category: Filter::PostFilter::RECENT }
    end
  end

  def show
    @main_program_show_url = true
    @programchat = Message.where(:program_id=>@program.id)
    @posts = Filter::PostFilter.call({ category: 'recent', program_ids: [@program.id] }, 1, 2)
    # @programfiles = GDriveFile.where(:program_id=>@program.id).order("created_at DESC").limit(5)
    @programfiles = {:items=>[]}
    begin
      drive = Google::Apis::DriveV2::DriveService.new
      auth_client = auth_svcacc_gdrive
      drive.authorization = auth_client
      # @programfiles = GDriveFile.where(:program_id=>@program.id).order("created_at DESC").limit(5)
      @programfiles = drive.list_files(q: "'#{@program.gdrive_folder_id}' in parents", max_results: 5, order_by: 'modifiedDate desc', fields: "items(modifiedDate,iconLink,alternateLink,title,id),next_page_token,self_link", options: { authorization: auth_client })
      @programfiles = @programfiles.to_h
    rescue Exception => e
      Rails.logger.info e.inspect
    end
  end

  def new
    @program = Program.new

    if params[:object_type].present?
      @program.object_type = params[:object_type].to_i
    end
    if params[:parent].present?
      @program.parent = params[:parent]
    end
  end

  def edit; end

  def create
    extra_program_params = Hash.new

    @program = Program.new(program_params.merge(extra_program_params))
    program_save = @program.save

    if program_save
      begin
        drive = Google::Apis::DriveV2::DriveService.new
        drive.authorization = auth_svcacc_gdrive
        folder_name = program_params['name']
        if Rails.env.staging?
          folder_name += "_staging"
        elsif Rails.env.development?
          folder_name += "_dev"
        end
        drive_file = drive.insert_file({title:folder_name,mime_type:"application/vnd.google-apps.folder"})
        extra_program_params['gdrive_folder_id'] = drive_file.to_h[:id]
      rescue Exception => e
        Rails.logger.info e.inspect
      end

      begin
        mu = ProgramUserRole.new
        mu.user_id = current_user.id
        mu.program_id = @program.id
        mu.role = current_user.role
        mu.pending = false
        mu.save
      rescue Exception => e
        Rails.logger.info e.inspect
      end
    end
    respond_to do |format|
      if program_save
        Activity.create!(
          activity: "Create a new #{@program.object_type} **[#{@program.name}](#{program_path(@program)})**",
          user: current_user,
        )

        format.html {
          notice = if @program.program_type?
                    'Program was successfully created.'
                   else
                    'Project was successfully added.'
                   end
          redirect_to @program, notice: notice
        }
        format.json { render :show, status: :created, location: @program }
        format.js
      else
        format.html { render :new }
        format.json { render json: @program.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def update
    respond_to do |format|
      if @program.update(program_params)
        Activity.create!(
          activity: "Updated a #{@program.object_type} **[#{@program.name}](#{program_path(@program)})**",
          user: current_user
        )
        format.html {
          notice = if @program.program_type?
                    'Program was successfully updated.'
                   else
                    'Project was successfully updated.'
                   end
          redirect_to @program, notice: notice
        }
        format.json { render :show, status: :ok, location: @program }
        format.js
      else
        format.html { render :edit }
        format.json { render json: @program.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def destroy
    deleted_program = @program
    if @program.destroy
      Activity.create!(
        activity: "Deleted a #{@program.object_type} **#{deleted_program.name}**",
        user: current_user,
      )
    end
    respond_to do |format|
      format.html { redirect_to programs_url, notice: "#{deleted_program.object_type.humanize} was successfully destroyed." }
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
      if !params["program_file_search_term"].nil?
        @program_file_search_term = params["program_file_search_term"]
        if @program_file_page.nil?
          @programfiles = sva_drive.list_files(q: "'#{@program.gdrive_folder_id}' in parents and title contains '#{@program_file_search_term}'", max_results: 20, order_by: sort_by, fields: "items(modifiedDate,iconLink,alternateLink,title,id),next_page_token,self_link", options: { authorization: auth_client })
        else
          @programfiles = sva_drive.list_files(q: "'#{@program.gdrive_folder_id}' in parents and title contains '#{@program_file_search_term}'", max_results: 20, page_token: @program_file_page, order_by: sort_by, fields: "items(modifiedDate,iconLink,alternateLink,title,id),next_page_token,self_link", options: { authorization: auth_client })
        end
      else
        if @program_file_page.nil?
          @programfiles = sva_drive.list_files(q: "'#{@program.gdrive_folder_id}' in parents", max_results: 20, page_token: @program_file_page, order_by: sort_by, fields: "items(modifiedDate,iconLink,alternateLink,title,id),next_page_token,self_link", options: { authorization: auth_client })
        else
          @programfiles = sva_drive.list_files(q: "'#{@program.gdrive_folder_id}' in parents", max_results: 20, page_token: @program_file_page, order_by: sort_by, fields: "items(modifiedDate,iconLink,alternateLink,title,id),next_page_token,self_link", options: { authorization: auth_client })
        end
      end
      @programfiles = @programfiles.to_h
      @program_file_next_page = @programfiles[:next_page_token]
      @program_file_page = [:self_link]
      @params = params
    end

    def set_program
      @program = Program.friendly.find(params[:id])
      @members = ProgramUserRole.where(program_id: @program.id)
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
    def program_params
      params.require(:program).permit(
        :name, :gdrive_folder_id, :description, :objectives,
        :cover, :cover_dy, :remove_cover, :object_type, :parent
      )
    end

    def resolve_layout
      case action_name
      when "index"
        "application"
      else
        "program"
      end
    end
end
