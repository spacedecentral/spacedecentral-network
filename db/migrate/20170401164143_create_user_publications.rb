class CreateUserPublications < ActiveRecord::Migration[5.0]
  def change
    create_table :user_publications do |t|
      t.references :user, foreign_key: true
      t.string :summary

      t.timestamps
    end
  end
end
