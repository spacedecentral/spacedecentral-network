class AddMailedColumnToNotifications < ActiveRecord::Migration[5.0]
  def change
    add_column :notifications, :mailed, :integer, null: false, default: 0
  end
end
