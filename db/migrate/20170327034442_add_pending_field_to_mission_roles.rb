class AddPendingFieldToMissionRoles < ActiveRecord::Migration[5.0]
  def change
    add_column :mission_user_roles, :pending, :boolean
  end
end
