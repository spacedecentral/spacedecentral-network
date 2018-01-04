class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :sender, class_name: User, foreign_key: :from_user
  belongs_to :notifiable, polymorphic: true

  validates :user, presence: true

  before_save :sanitize_notification_template_path

  def read!
    self.read = true
    self.save
  end

  def self.notify(receiver_id, sender_id, options = {})
    options = {
      template: 'notifications/_notification_in_nav',
      event: '',
    }.deep_merge(options)

    notification = self.create!(
      event: options[:event],
      user_id: receiver_id,
      from_user: sender_id,
      read: false,
      notifiable: options[:notifiable],
      template: options[:template]
    )

    dom_update = ApplicationController.render(
      template: options[:template],
      layout: false,
      locals: { notification: notification }
    )

    ActionCable.server.broadcast(
      "app_notifier_#{receiver_id}",
      new_notification: 1,
      dom_update: dom_update
    )
  rescue StandardError => e
    Rails.logger.info e.inspect
  end

  private

  def sanitize_notification_template_path
    self.template = template.gsub(/(\/_)/, '/')
  end
end
