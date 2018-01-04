class NotifierChannel < ApplicationCable::Channel
  def subscribed
    if current_user
      # SubscriberTracker.set_online "app_notifier_#{current_user.id}"
      stream_from "app_notifier_#{current_user.id}"
    end
  end

  def unsubscribed
    # SubscriberTracker.set_offline "app_notifier_#{current_user.id}"
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
  end
end
