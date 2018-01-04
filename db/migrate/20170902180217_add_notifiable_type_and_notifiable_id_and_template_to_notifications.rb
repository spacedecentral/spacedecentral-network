class AddNotifiableTypeAndNotifiableIdAndTemplateToNotifications < ActiveRecord::Migration[5.0]
  def change
    add_column :notifications, :notifiable_type, :string
    add_column :notifications, :notifiable_id, :integer, index: true
    add_column :notifications, :template, :string

    Notification.destroy_all
  end
end
