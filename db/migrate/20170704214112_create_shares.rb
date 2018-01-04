class CreateShares < ActiveRecord::Migration[5.0]
  def change
    create_table :shares do |t|
      t.integer :user
      t.integer :post

      t.timestamps
    end
  end
end
