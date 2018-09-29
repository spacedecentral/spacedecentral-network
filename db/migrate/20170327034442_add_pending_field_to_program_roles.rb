class AddPendingFieldToProgramRoles < ActiveRecord::Migration[5.0]
  def change
    add_column :program_user_roles, :pending, :boolean
  end
end
