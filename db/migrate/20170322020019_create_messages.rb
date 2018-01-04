class CreateMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :messages do |t|
      t.text :body
      t.references :user, foreign_key: true
      t.integer :user_to
      t.references :conversation, foreign_key: true

      t.timestamps
    end
  end
end
