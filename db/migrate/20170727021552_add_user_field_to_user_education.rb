class AddUserFieldToUserEducation < ActiveRecord::Migration[5.0]
  def change
    add_reference :user_educations, :user, foreign_key: true
  end
end
