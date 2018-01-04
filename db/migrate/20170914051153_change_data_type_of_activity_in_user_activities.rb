class ChangeDataTypeOfActivityInUserActivities < ActiveRecord::Migration[5.0]
  def change
    change_column :activities, :activity, :text
  end
end
