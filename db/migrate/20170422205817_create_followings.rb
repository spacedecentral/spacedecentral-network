class CreateFollowings < ActiveRecord::Migration[5.0]
  def change
    create_table :followings do |t|
      t.references :user, foreign_key: true
      t.integer :follow_user

      t.timestamps
    end
  end
end
