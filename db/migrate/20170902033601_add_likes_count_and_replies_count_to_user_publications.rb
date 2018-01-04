class AddLikesCountAndRepliesCountToUserPublications < ActiveRecord::Migration[5.0]
  def change
    add_column :user_publications, :likes_count, :integer, default: 0
    add_column :user_publications, :replies_count, :integer, default: 0
  end
end
