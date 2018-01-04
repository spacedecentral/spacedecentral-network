class AddFieldGroupCountToConversation < ActiveRecord::Migration[5.0]
  def change
    add_column :conversations, :group_size, :integer
  end
end
