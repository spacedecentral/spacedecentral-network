class CreateReplies < ActiveRecord::Migration[5.0]
  def change
    create_table :replies do |t|
      t.text :content
      t.references :user, foreign_key: true
      t.references :post, foreign_key: true
      t.integer :parent_reply

      t.timestamps
    end
    add_index :replies, [:user_id, :post_id, :created_at]
  end
end
