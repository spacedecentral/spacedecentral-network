class RemoveSubjectFromMessage < ActiveRecord::Migration[5.0]
  def change
    remove_column :messages, :subject
  end
end
