class ConversationsController < ApplicationController

  def index

    respond_to do |format|
      format.html
      format.json
      format.js
    end
  end
  
  def show
    @messages = Conversation.get_convo_messages(params[:id])
    #@messages = Message.where("conversation_id = ?", params[:id]) 
    
    @convo_id = params[:id]
    @reply_message = Message.new
    @reply_message.conversation_id = params[:id]
    begin
      convo = Conversation.find(params[:id])
      @group_users = GroupConvoReference.select("user_id").where("conversation_id = ? AND user_id <> ?",params[:id], current_user.id).map{|m| m.user_id }.to_a.join(",")
      current_group_member = GroupConvoReference.where("conversation_id = ? AND user_id = ?",params[:id], current_user.id).first
      if !current_group_member.read
        begin
          ActionCable.server.broadcast "app_notifier_#{current_user.id}", decrement_message_unread: 1, conversation_id: params[:id]
        rescue Exception => e
          Rails.logger.info e.inspect
        end
        Rails.logger.info "Marked convo as read"
        current_group_member.read = true
        current_group_member.save
      end
    rescue Exception=>e
      Rails.logger.info e.inspect
    end
    respond_to do |format|
      format.html
      format.json
      format.js
    end
  end

end
