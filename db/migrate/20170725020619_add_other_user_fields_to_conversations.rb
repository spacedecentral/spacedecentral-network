class AddOtherUserFieldsToConversations < ActiveRecord::Migration[5.0]
  def change
    add_column :conversations, :user_2_id, :integer
    add_reference :conversations, :message, foreign_key: true
    add_column :conversations, :read, :boolean, default: false
  end
end
