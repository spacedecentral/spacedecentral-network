class AddProgramToTagReferences < ActiveRecord::Migration[5.0]
  def change
    add_column :tag_references, :program_id, :int
    add_foreign_key :tag_references, :programs
  end
end
