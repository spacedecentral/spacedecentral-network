class AddMissionToTagReferences < ActiveRecord::Migration[5.0]
  def change
    add_column :tag_references, :mission_id, :int
    add_foreign_key :tag_references, :missions
  end
end
