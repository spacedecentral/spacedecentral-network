class CreateUserPublicationPermissions < ActiveRecord::Migration[5.0]
  def change
    create_table :user_publication_permissions do |t|
      t.belongs_to :user_publication, foreign_key: true
      t.belongs_to :user, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end
