class AddFieldObjectivesToMission < ActiveRecord::Migration[5.0]
  def change
    add_column :missions, :objectives, :longtext
    add_column :missions, :cover_dy, :integer
  end
end
