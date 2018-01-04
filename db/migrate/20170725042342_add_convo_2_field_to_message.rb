class AddConvo2FieldToMessage < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :conversation_2_id, :integer
  end
end
