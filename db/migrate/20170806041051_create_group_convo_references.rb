class CreateGroupConvoReferences < ActiveRecord::Migration[5.0]
  def change
    create_table :group_convo_references do |t|
      t.references :conversation, foreign_key: true
      t.references :user, foreign_key: true
      t.boolean :read, default: false

      t.timestamps
    end
  end
end
