class AddProgramFieldToMessage < ActiveRecord::Migration[5.0]
  def change
    add_reference :messages, :program, foreign_key: true
  end
end
