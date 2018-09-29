class AddObjectTypeToPrograms < ActiveRecord::Migration[5.0]
  def change
    add_column :programs, :object_type, :integer, default: 1
    add_column :programs, :members_count, :integer, default: 0
  end
end
