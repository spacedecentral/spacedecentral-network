class CreateLikes < ActiveRecord::Migration[5.0]
  def change
    create_table :likes do |t|
      t.integer :user
      t.integer :post

      t.timestamps
    end
  end
end
