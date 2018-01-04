class AddLikesCountAndRepliesCountToReplies < ActiveRecord::Migration[5.0]
  def change
    add_column :replies, :likes_count, :integer, default: 0
    add_column :replies, :replies_count, :integer, default: 0
  end
end
