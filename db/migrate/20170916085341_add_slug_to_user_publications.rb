class AddSlugToUserPublications < ActiveRecord::Migration[5.0]
  def change
    add_column :user_publications, :slug, :string, limit: 400, index: true
  end
end
