class AddGdriveFolderIdFieldToMission < ActiveRecord::Migration[5.0]
  def change
    add_column :missions, :gdrive_folder_id, :string
  end
end
