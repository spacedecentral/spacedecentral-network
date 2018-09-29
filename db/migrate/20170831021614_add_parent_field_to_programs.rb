class AddParentFieldToPrograms < ActiveRecord::Migration[5.0]
  def change
    add_column :programs, :parent, :integer
  end
end
