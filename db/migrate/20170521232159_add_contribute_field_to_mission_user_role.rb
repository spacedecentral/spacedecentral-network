class AddContributeFieldToMissionUserRole < ActiveRecord::Migration[5.0]
  def change
    add_column :mission_user_roles, :contribute, :text
    add_column :mission_user_roles, :availability, :string
  end
end
