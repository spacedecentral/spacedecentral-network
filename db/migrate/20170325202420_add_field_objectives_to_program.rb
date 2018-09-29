class AddFieldObjectivesToProgram < ActiveRecord::Migration[5.0]
  def change
    add_column :programs, :objectives, :longtext
    add_column :programs, :cover_dy, :integer
  end
end
