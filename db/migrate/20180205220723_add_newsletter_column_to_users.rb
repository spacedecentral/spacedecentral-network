class AddNewsletterColumnToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :newsletter, :boolean
  end
end
