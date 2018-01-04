class PolimorphicReplies < ActiveRecord::Migration[5.0]
  def up
    add_column :replies, :replicable_type, :string
    rename_column :replies, :post_id, :replicable_id
    remove_column :replies, :parent_reply
    remove_foreign_key :replies, :posts
  end

  def down
    remove_column :replies, :replicable_type
    rename_column :replies, :replicable_id, :post_id
    add_column :replies, :parent_reply, :integer, index: true
    add_foreign_key :replies, :posts, dependent: :delete
  end
end
