class MissionChatChannel < ApplicationCable::Channel
  def subscribed
    if params["mission_chat_id"]
      if MissionUserRole.where(:mission_id=>params["mission_chat_id"],:user_id=>current_user.id).exists?
        stream_from params["mission_chat_id"]
        # stream_for params["mission_chat_id"]
      end
    end
    # stream_from params["mission_chat_id"]
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    message = Message.new
    if data['save_in_convo']
      begin
        message = Message.new
        message.body = data['message']
        message.user_id = current_user.id
        message.mission_id = data['mission_chat_id']
        message.read = true
        message.save
        Rails.logger.debug(message.errors.inspect)
      rescue
      end
    end
    timenow = DateTime.now.strftime('%m-%d-%y %l:%M %P')
    ActionCable.server.broadcast data['mission_chat_id'], name: current_user.name.to_s, message: data['message'], time: timenow
  end
end
