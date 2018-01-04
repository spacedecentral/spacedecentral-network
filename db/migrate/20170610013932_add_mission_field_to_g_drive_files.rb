class AddMissionFieldToGDriveFiles < ActiveRecord::Migration[5.0]
  def change
    add_reference :g_drive_files, :mission, foreign_key: true
    add_column :g_drive_files, :icon_link, :string
  end
end
