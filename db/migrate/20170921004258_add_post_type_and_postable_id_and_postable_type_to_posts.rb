class AddPostTypeAndPostableIdAndPostableTypeToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :post_type, :integer, default: 0
    add_column :posts, :postable_type, :string
    add_column :posts, :postable_id, :integer
    add_index :posts, :postable_id
  end
end
