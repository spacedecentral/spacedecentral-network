class AddSlugFieldToMissions < ActiveRecord::Migration[5.0]
  def change
    add_column :missions, :slug, :string
    add_index :missions, :slug, unique: true
  end
end
