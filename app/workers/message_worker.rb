class MessageWorker
  include Sidekiq::Worker

  def perform(message,convo_id,current_user_id,group_sent,group_found,save_group_ref,dom_nav_update,dom_convo_update)
    begin
      fromUser = Hash.new
      if group_sent.size > 2
          fromUser = User.find(current_user_id)
      end
      group_sent.each do |user|
        logger.info ":::::usersync- "+user.to_s
        # if save_group_ref
        groupref = GroupConvoReference.find_or_create_by(:conversation_id=> convo_id, :user_id=>user)
        # end
        if user != current_user_id
          Sidekiq.redis do |conn|
            logger.info 'redis conn : '+conn.get("app_notifier_#{user}").inspect
            # ignore if the conn is nil atm it doesnt work so just assume online
            # will make a cronjob to send an email sometime
            if 1==1 || conn.get("app_notifier_#{user}").to_i == 1
              # if user current logged in send over the cable
              ActionCable.server.broadcast "app_notifier_#{user}", new_message: 1, dom_nav_update: dom_nav_update, dom_convo_update: dom_convo_update, mark_as_unread: 1, conversation_id: convo_id
              #otherwise send the user an email notification
            else
              if groupref.read
                if group_sent.size <= 2
                  fromUser = User.find(current_user_id)
                end
                toUser = User.find(user)
                ApplicationMailer.new_spacedecentral_message(fromUser,toUser,message).deliver
              end
            end
          end
        end
      end
      GroupConvoReference.where(:conversation_id=>convo_id,:read=>true).where.not(:user_id=>current_user_id).update_all(:read=>false)
    rescue Exception => e
      logger.info e.inspect
    end
  end

end
