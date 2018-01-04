module UsersHelper

  def list_user_active_status(user)
    if user.role.nil?
      content_tag(:b, class: "orange") do
        "Pending Activation"
      end
    elsif user.is_suspended_role?
      content_tag(:b, class: "red") do
        "Suspended"
      end
    else
      content_tag(:b, class: "green") do
        "Activated"
      end
    end
  end

end
