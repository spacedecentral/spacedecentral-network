class NotifiersController < ApplicationController
   before_action :authenticate_user!, :except => [:digest, :immediate]

  protect_from_forgery with: :null_session

# mysql> select n.id, n.event, n.user_id, n.notifiable_type, u.email, u.name, u.notifications, n.read from notifications n join users u on n.user_id = u.id where n.read = 1 and u.notifications = 2;

#  1 == Immediately after each event
#  2 == Daily summary of events
#  3 == No mail notifications at all


  def get_users(notification_type)
Rails.logger.info " ---- " + notification_type.to_s
    notifs = Notification.joins("JOIN users ON notifications.user_id = users.id and notifications.read = 0 and users.notifications = #{notification_type}")
    .pluck(:user_id,:name,:email,:notifications,:event)
    .map { |user_id, name, email, notifications, event| {user_id: user_id, name: name, email: email, notifications: notifications, event: event}}

    users = {}

    notifs.each do |n|

      Rails.logger.info n.to_s

      if users.has_key?(n[:user_id])
        users[:user_id].push(n)
      else
        users[:user_id] = [ n ]
      end
    end

    return users

  end

  def send_notifs(notification_type, subject)
    users = get_users(notification_type)
    Rails.logger.info users.to_s

    message = ''

    users.each do |user_id, events|
      message = ''
      events.each do |event|
        message << event.event
      end

      @notifiee = {
        :name => name,
        :subject => subject,
        :email => email,
        :message => message
      }

      NotifierMailer.notify().deliver_now
    end
  end

  def immediate
    head :unauthorized and return if !Socket.ip_address_list.select(&:ipv4?).map(&:ip_address).include?(request.remote_ip)
    subject = 'You have unread messages on SpaceDecentral.Net'
    send_notifs(1, subject)
Rails.logger.info " --=-- " + p.to_s
  end

  def digest
    head :unauthorized and return if !Socket.ip_address_list.select(&:ipv4?).map(&:ip_address).include?(request.remote_ip)
    subject = 'You have unread messages on SpaceDecentral.Net (daily digest)'
Rails.logger.info " --+-- " + subject
    send_notifs(2, subject)
  end

end

