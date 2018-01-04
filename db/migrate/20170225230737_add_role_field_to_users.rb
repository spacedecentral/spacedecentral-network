class AddRoleFieldToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :role, :int
    add_column :users, :cover_dy, :integer
    add_column :users, :bio, :text
    add_column :users, :provider, :string
    add_column :users, :string, :string
    add_column :users, :uid, :string
    add_column :users, :name, :string
  end
end
