class AddLinkageColumnToNotifications < ActiveRecord::Migration[5.0]
  def change
    add_column :notifications, :linkage, :string, null: false, default: ''
  end
end
