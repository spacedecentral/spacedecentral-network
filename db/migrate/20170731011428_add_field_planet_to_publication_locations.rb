class AddFieldPlanetToPublicationLocations < ActiveRecord::Migration[5.0]
  def change
    add_column :publication_long_lats, :planet, :string
  end
end
