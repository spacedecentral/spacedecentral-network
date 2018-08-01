class AddNotificationsColumnToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :notifications, :integer, null: false, default: 1
  end
end
