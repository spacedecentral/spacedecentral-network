class LikesPolymorphic < ActiveRecord::Migration[5.0]
  def up
    rename_column :likes, :post, :likable_id
    rename_column :likes, :user, :user_id
    add_column :likes, :likable_type, :string
  end

  def down
    rename_column :likes, :likable_id, :post
    rename_column :likes, :user_id, :user
    remove_column :likes, :likable_type
  end
end
