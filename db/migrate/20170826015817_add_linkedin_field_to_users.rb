class AddLinkedinFieldToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :linkedin_url, :string
  end
end
