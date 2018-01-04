class ChangeContentTypeInPosts < ActiveRecord::Migration[5.0]
  def change
  	change_column :posts, :content, :text
  end
end
