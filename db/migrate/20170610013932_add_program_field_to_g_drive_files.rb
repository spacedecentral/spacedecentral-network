class AddProgramFieldToGDriveFiles < ActiveRecord::Migration[5.0]
  def change
    add_reference :g_drive_files, :program, foreign_key: true
    add_column :g_drive_files, :icon_link, :string
  end
end
