class CreateGDriveFiles < ActiveRecord::Migration[5.0]
  def change
    create_table :g_drive_files do |t|
      t.string :title
      t.string :direct_link
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
