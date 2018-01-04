module MissionUserRolesHelper


  def render_crews_menu(current_user, member, current_user_mission_role)
    menus = Hash.new
    if current_user.is_admin_user? || current_user_mission_role.is_coordinator_or_greater?
      menus = { MissionUserRole::COORDINATOR_ROLE=>'Make Coordinator', MissionUserRole::DESIGNER_ROLE=>'Make Designer', MissionUserRole::TRAINEE_ROLE=>'Make Trainee' }
    end
    raw(
      (menus.map { |key, value|
        content_tag('li') {
          link_to value, mission_mission_user_role_path(member.mission.slug, member.id, role: key), method: :patch
        }
      }).push(
        content_tag('li') {         
          if current_user.is_admin_user? || current_user_mission_role.is_coordinator_or_greater?
            link_to 'Remove From Mission', mission_mission_user_role_path(member.mission.slug, member.id), method: :delete, remote: true
          end
        }
      ).join('')
    )
  end


end
