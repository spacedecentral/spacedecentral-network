class UserPublicationPermission < ApplicationRecord
  belongs_to :user_publication
  belongs_to :requester, class_name: User, foreign_key: :user_id
  has_many :notifications, as: :notifiable, dependent: :destroy

  include AASM

  aasm(:status) do
    state :requested, initial: true
    state :approved
    state :denied

    event :request do
      transitions from: :denied, to: :requested,
        after: :notify_requested!
    end

    event :approve do
      transitions from: [:requested, :denied], to: :approved,
        after: :notify_approved!
    end

    event :deny do
      transitions from: [:requested, :approved], to: :denied,
        after: :notify_denied!
    end
  end

  def notify_requested!
    # send to owner's publication
    Notification.notify(
      user_publication.user_id,
      self.user_id,
      template: 'notifications/_notification_publication_request',
      notifiable: self
    )
  end

  private

  def notify_approved!
    notify_event('approved')
  end

  def notify_denied!
    notify_event('denied')
  end

  def notify_event(event)
    owner_id = user_publication.user_id
    # send to requester
    Notification.notify(
      self.user_id,
      owner_id,
      template: 'notifications/_notification_publication_approved',
      notifiable: self,
      event: event
    )
    mark_notification_related_as_read
  end

  def mark_notification_related_as_read
    notifications.where(from_user: self.user_id).update_all(read: true)
  end
end
