class AdditionalAuthorsForPublication < ActiveRecord::Migration[5.0]
  def change
    rename_column :user_publications, :authors, :additional_authors
  end
end
