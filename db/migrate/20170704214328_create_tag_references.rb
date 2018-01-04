class CreateTagReferences < ActiveRecord::Migration[5.0]
  def change
    create_table :tag_references do |t|
      t.references :tag, foreign_key: true
      t.references :post, foreign_key: true
      t.references :user_publication, foreign_key: true

      t.timestamps
    end
  end
end
