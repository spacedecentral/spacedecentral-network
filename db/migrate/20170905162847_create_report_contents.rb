class CreateReportContents < ActiveRecord::Migration[5.0]
  def change
    create_table :report_contents do |t|
      t.integer :user_id
      t.string :reportable_type
      t.integer :reportable_id
      t.integer :report_type
      t.string :report_parent_type
      t.integer :report_parent_id

      t.timestamps
    end
    add_index :report_contents, :user_id
    add_index :report_contents, :reportable_id
    add_index :report_contents, :report_parent_id
  end
end
