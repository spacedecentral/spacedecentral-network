class AddContributeFieldToProgramUserRole < ActiveRecord::Migration[5.0]
  def change
    add_column :program_user_roles, :contribute, :text
    add_column :program_user_roles, :availability, :string
  end
end
