class AddTitleFieldToUserPublications < ActiveRecord::Migration[5.0]
  def change
    add_column :user_publications, :title, :string
  end
end
