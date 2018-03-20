class AddPinnedToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :pinned, :boolean, default: false, null: false
  end
end
