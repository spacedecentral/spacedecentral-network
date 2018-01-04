class AddObjectTypeToMissions < ActiveRecord::Migration[5.0]
  def change
    add_column :missions, :object_type, :integer, default: 1
    add_column :missions, :members_count, :integer, default: 0
  end
end
