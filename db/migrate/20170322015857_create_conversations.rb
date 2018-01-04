class CreateConversations < ActiveRecord::Migration[5.0]
  def change
    create_table :conversations do |t|

      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
