class ReplaceMissionWithProgram < ActiveRecord::Migration[5.0]
  def change
	change_table :g_drive_files do |t|
		t.rename :mission_id, :program_id
	end
	change_table :messages do |t|
		t.rename :mission_id, :program_id
	end
	change_table :mission_user_roles do |t|
		t.rename :mission_id, :program_id
	end
	change_table :missions do |t|
		t.rename_index :index_missions_on_slug, :index_programs_on_slug
	end
	change_table :mission_user_roles do |t|
		t.rename_index :index_mission_user_roles_on_mission_id, :index_program_user_roles_on_program_id
	end
	change_table :tag_references do |t|
		t.rename :mission_id, :program_id
	end
	rename_table :mission_user_roles, :program_user_roles
	rename_table :missions, :programs
  end
end
