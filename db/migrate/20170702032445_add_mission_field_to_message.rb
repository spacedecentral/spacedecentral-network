class AddMissionFieldToMessage < ActiveRecord::Migration[5.0]
  def change
    add_reference :messages, :mission, foreign_key: true
  end
end
