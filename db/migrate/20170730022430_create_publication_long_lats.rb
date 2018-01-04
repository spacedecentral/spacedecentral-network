class CreatePublicationLongLats < ActiveRecord::Migration[5.0]
  def change
    create_table :publication_long_lats do |t|
      t.float :longitude
      t.float :latitude
      t.float :max_long
      t.float :max_lat
      t.references :user_publication, foreign_key: true

      t.timestamps
    end
  end
end
