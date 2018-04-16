module ProgramUserRolesHelper


  def render_crews_menu(current_user, member, current_user_program_role)
    menus = Hash.new
    if current_user.is_admin_user? || current_user_program_role.is_coordinator_or_greater?
      menus = { ProgramUserRole::COORDINATOR_ROLE=>'Make Coordinator', ProgramUserRole::DESIGNER_ROLE=>'Make Designer', ProgramUserRole::TRAINEE_ROLE=>'Make Trainee' }
    end
    raw(
      (menus.map { |key, value|
        content_tag('li') {
          link_to value, program_program_user_role_path(member.program.slug, member.id, role: key), method: :patch
        }
      }).push(
        content_tag('li') {         
          if current_user.is_admin_user? || current_user_program_role.is_coordinator_or_greater?
            link_to 'Remove From Program', program_program_user_role_path(member.program.slug, member.id), method: :delete, remote: true
          end
        }
      ).join('')
    )
  end


end
