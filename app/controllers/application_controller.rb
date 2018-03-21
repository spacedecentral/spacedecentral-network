class ApplicationController < ActionController::Base
  before_action :http_authenticate
  before_action :authenticate_user!
  before_action :set_global_user, :set_messages, :set_notifications
  before_filter :store_location, :set_cache_headers

  protect_from_forgery with: :exception, prepend: :true

  def store_location
    # store last url - this is needed for post-login redirect to whatever the user last visited.
    return unless request.get?
    if ( !request.path.include?("/log-in") &&
        !request.path.include?("/users/auth/google_oauth2/callback") &&
        !request.path.include?("/users/sign_up") &&
        !request.path.include?("/users/confirmation") &&
        !request.path.include?("/users/password/new") &&
        !request.path.include?("/users/password/edit") &&
        !request.xhr?) # don't store ajax calls
      session[:previous_url] = request.fullpath
    end
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end

  def http_authenticate
    return if Rails.env.production? || Rails.env.development? || Rails.env.test?

    authenticate_or_request_with_http_basic do |username, password|
      username == ENV["HTTP_AUTH_USERNAME"] && password == ENV["HTTP_AUTH_PASSWORD"]
    end
  end

  def handle_tag_params(tag_list)
    return [] unless tag_list

    return @tag_ids if @tag_ids.present?

    new_tags_string = []
    tag_ids = []

    tag_list.split(',').each do |item|
      if int?(item)
        tag_ids << item
      else
        new_tags_string << item
      end
    end

    new_tag_ids = new_tags_string.map do |tag|
      Tag.find_or_create_by(tag: tag).id
    end

    @tag_ids = tag_ids + new_tag_ids
  end

  def int?(number)
    Integer(number) rescue false
  end

  private
    def set_cache_headers
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    end

    def set_global_user
      return if skip_controllers
      begin
      @current_user = current_user
      rescue Exception => e
        flash[:error] = "There was an issue with your login attempt."
      end
      if !Rails.env.test?
        if !current_user.nil? && cookies&.permanent&.signed[:user_id].nil?
          cookies.permanent.signed[:user_id] = current_user.id
        end
      end
      # Rails.logger.info "*****-- #{cookies.permanent.signed[:user_id]}"
    end

    def set_messages
      return if skip_controllers
      @conversations = Array.new
      @conversations_unread = 0
      if !@current_user.nil?
        #g = GroupConvoReference.column_names.map{|f| 'g.'+f.to_s+' AS g_'+f.to_s }
        #c = Conversation.column_names.map{|f| 'c.'+f.to_s+' AS c_'+f.to_s }
        #m = Message.column_names.map{|f| 'm.'+f.to_s+' AS m_'+f.to_s }
        #u = User.column_names.map{|f| 'u.'+f.to_s+' AS u_'+f.to_s }
        #selectfields = (g + c + m + u).join(',')
        # query = "SELECT #{selectfields} "
        query = "SELECT c.id AS c_id, m.user_id AS m_user_id, m.body AS m_body, m.created_at AS m_created_at, g.read AS g_read, "
        query += " u.id AS u_id, u.email AS u_email, u.name AS u_name, u.avatar_file_name AS u_avatar_file_name, u.avatar_content_type AS u_avatar_content_type "
        query += " FROM group_convo_references as g, conversations as c, messages as m, users as u "
        query += " WHERE g.conversation_id = c.id AND c.message_id = m.id AND m.user_id = u.id AND g.user_id = #{current_user.id}"
        query += " ORDER BY c.updated_at DESC"
        @conversations = ActiveRecord::Base.connection.select_all(query).to_hash
        # Rails.logger.info @conversations.inspect
        @conversations_unread = GroupConvoReference.where(:user_id=>current_user.id,:read=>false).count
      end
    end

    def set_notifications
      return if skip_controllers
      @notifications = Array.new
      @notifications_unread = 0
      if !@current_user.nil?
        @notifications = Notification.where(user_id: @current_user.id).order('created_at DESC')
        @notifications_unread = @notifications.where(:read=>false).count
      end
    end

    def skip_controllers
      (%w[attachments tags tag_references user_careers publication_authors
      publication_long_lats].include?(controller_name) || request.xhr?)
    end
end
