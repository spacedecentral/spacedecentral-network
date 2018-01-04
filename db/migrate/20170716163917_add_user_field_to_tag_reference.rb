class AddUserFieldToTagReference < ActiveRecord::Migration[5.0]
  def change
    add_reference :tag_references, :user, foreign_key: true
  end
end
