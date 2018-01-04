class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :edit, :update, :destroy]


  def show
    begin
      convo = @message.conversation
      if !convo.read
        begin
          ActionCable.server.broadcast "app_notifier_#{current_user.id}", decrement_message_unread: 1
        rescue Exception => e
          Rails.logger.info e.inspect
        end
      end
      convo.read = true
      convo.save
      Rails.logger.info "Marked convo as read"
    rescue Exception=>e
      Rails.logger.info e.inspect
    end
    respond_to do |format|
      format.html
      format.json
      format.js
    end
  end

  # GET /messages/new
  def new
    @message = Message.new
    @user_to_id = params["user_to"]
    @user_to_name = params["user_to_name"]
    params['group_users'] = params["user_to"]
  end

  # POST /messages
  # POST /messages.json
  def create
    message_save = false
    @message = Message.new(message_params.merge(user_id: current_user.id, read: false))
    if params['group_users'].blank?
      @message.errors.add(:conversation_id, "you need at least 1 recipient")
    else
      begin
        group_given =  params['group_users'].split(',').map(&:to_i).push(current_user.id).uniq
        Rails.logger.info group_given.inspect
        if group_given.size == 1
          @message.errors.add(:conversation_id, "you cannot send a message to yourself")
        else
          # not sure if we should trust the id coming from the params on the FE
          # someone could manipulate themselves into another conversation or update the members in a conversation
          # for now finding the 'conversation_id' using the members and the size and ignoring the FE
          # maybe with other DB checks validations deletions of exsiting updates etc 
          # but for now this is safer
          # if message_params['conversation_id']&.empty?
          groups_found = GroupConvoReference.find_conversation_by_group_size_and_members(group_given.join(','), group_given.size)
          conversations_found = groups_found.group_by(&:conversation_id)
          Rails.logger.info conversations_found
          if conversations_found.size > 1
            # this should be some sort of error in DB 
            # there shouldnt be 2 conversations of the same group size with the same users
          end
          # all groups_found should have the same conversation_id
          save_group_ref = false
          if !groups_found.empty?
             conversations_found.each do |key, group|
               convo_group = group.map{|g| g['user_id'] }.uniq
               Rails.logger.info convo_group.inspect
                if (group_given - convo_group).blank? && (convo_group - group_given).blank?
                  @convo = Conversation.find(key.to_i)
                  break
                end
            end
            #@convo = Conversation.where(:id=>groups_found.first["conversation_id"]).first
          end
          # other case to check message_params['conversation_id'] from the FE does exist
          # else
          # @convo = Conversation.find(message_params['conversation_id'])
          # save_group_ref = group_found.size < group_given.size
          # end
          if @convo.nil?
            @convo = Conversation.new
            @convo.save
            save_group_ref = true
          end
          @message.conversation_id = @convo.id
          message_save = @message.save
          @convo.message_id = @message.id
          @convo.group_size = group_given.size
          @convo.save

          @message_in_nav = {
            "c_id"=>@convo.id,
            "m_user_id"=>current_user.id,
            "m_created_at"=>@message.created_at,
            "m_body"=>@message.body,
            "g_read"=>false,
            "u_name"=>current_user.name,
            "u_id"=>current_user.id,
            "u_email"=>current_user.email,
            "u_avatar_file_name"=>current_user.avatar_file_name,
            "u_avatar_content_type"=>current_user.avatar_content_type
          }
          dom_nav_update = render_to_string('messages/_message_in_nav', :layout => false, :locals => { :message => @message_in_nav, :message_user=>current_user })
          dom_convo_update = render_to_string('messages/_message_in_convo', :layout => false, :locals => { :message => @message, :render_as_received=>true })
          Rails.logger.info "*****--***"+save_group_ref.inspect
          MessageWorker.perform_async(@message.to_json, @convo.id, current_user.id, group_given, groups_found, save_group_ref, dom_nav_update, dom_convo_update)    
          @reply_message = Message.new
          @reply_message.conversation_id = @convo.id
          @group_users = group_given.join(',')
          @convo_id = @convo.id
        end
      rescue Exception=> e
        @message.errors.add(:conversation_id, e.message)
      end
    end

    respond_to do |format|
      if message_save
        format.html { redirect_to @message, notice: 'Message was successfully created.' }
        format.json { render :show, status: :created, location: @message }
        format.js   { render :layout => false }
      else
        format.html { render :new }
        format.json { render json: @message.errors, status: :unprocessable_entity }
        format.js   { render :layout => false, status: 500 }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    if @message.user_id == current_user.id
      @message.destroy
    end
    respond_to do |format|
      format.html { redirect_to messages_url, notice: 'Message was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:body, :user_to, :subject, :conversation_id, :group_users)
    end
end
