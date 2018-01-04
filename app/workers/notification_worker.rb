class NotificationWorker
  include Sidekiq::Worker

  def perform(id,msg)
    followers = Following.where(:follow_user=>id)
    followers.each do |f|
        Notification.notify(
            f.user_id,
            id,
            event: msg
        )
    end
  end

end
