class AddAuthorsToUserPublications < ActiveRecord::Migration[5.0]
  def change
    add_column :user_publications, :authors, :text
  end
end
