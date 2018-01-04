class AddUserIdToPublicationAuthors < ActiveRecord::Migration[5.0]
  def change
    add_column :publication_authors, :user_id, :integer
    add_index :publication_authors, :user_id
  end
end
