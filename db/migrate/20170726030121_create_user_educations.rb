class CreateUserEducations < ActiveRecord::Migration[5.0]
  def change
    create_table :user_educations do |t|
      t.string :degree
      t.string :school
      t.string :graduation

      t.timestamps
    end
  end
end
