class AddParentFieldToMissions < ActiveRecord::Migration[5.0]
  def change
    add_column :missions, :parent, :integer
  end
end
