class MissionDecorator < ApplicationDecorator
  delegate_all

  def can_write?(role)
    (role && role.is_coordinator_or_greater?) ||
      (h.user_signed_in? && h.current_user.is_admin_user?) ||
      is_coordinator_or_greater_of_parent_mission?
  end

  def is_coordinator_or_greater_of_parent_mission?
    object.project_type? && object.dad.mission_user_roles.where(user: h.current_user).first&.is_coordinator_or_greater?
  end
end
