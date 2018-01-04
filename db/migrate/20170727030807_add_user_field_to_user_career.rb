class AddUserFieldToUserCareer < ActiveRecord::Migration[5.0]
  def change
    add_reference :user_careers, :user, foreign_key: true
  end
end
