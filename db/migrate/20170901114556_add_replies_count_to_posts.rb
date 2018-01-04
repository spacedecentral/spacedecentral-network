class AddRepliesCountToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :replies_count, :integer, default: 0
  end
end
