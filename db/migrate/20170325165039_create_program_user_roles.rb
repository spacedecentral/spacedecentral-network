class CreateProgramUserRoles < ActiveRecord::Migration[5.0]
  def change
    create_table :program_user_roles do |t|
      t.integer :role
      t.references :program, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
