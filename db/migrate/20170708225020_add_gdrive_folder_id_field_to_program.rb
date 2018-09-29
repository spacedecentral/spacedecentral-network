class AddGdriveFolderIdFieldToProgram < ActiveRecord::Migration[5.0]
  def change
    add_column :programs, :gdrive_folder_id, :string
  end
end
