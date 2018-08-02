class CreateWatchers < ActiveRecord::Migration[5.0]
  def change
    create_table :watchers do |t|
      t.references :user, foreign_key: true
      t.string :watchable_type
      t.integer :watchable_id
      t.datetime :created_at

      t.timestamps
    end
  end
end
