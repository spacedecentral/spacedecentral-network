class CreateUserCareers < ActiveRecord::Migration[5.0]
  def change
    create_table :user_careers do |t|
      t.string :position
      t.string :company
      t.string :from
      t.string :to

      t.timestamps
    end
  end
end
