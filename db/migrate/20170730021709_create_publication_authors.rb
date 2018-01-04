class CreatePublicationAuthors < ActiveRecord::Migration[5.0]
  def change
    create_table :publication_authors do |t|
      t.string :author
      t.references :user_publication, foreign_key: true

      t.timestamps
    end
  end
end
