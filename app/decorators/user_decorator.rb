class UserDecorator < ApplicationDecorator
  delegate_all

  def skills_chips
    object.skills.map do |skill|
      { id: skill.id, label: skill.tag }
    end.to_json
  end

  def following_empty_text
    if h.user_signed_in? && object.id == h.current_user.id
      'You have not followed anyone yet.'
    else
      'This user has not followed anyone yet.'
    end
  end

  def follower_empty_text
    if h.user_signed_in? && object.id == h.current_user.id
      'You have no followers yet.'
    else
      'This user has no followers yet.'
    end
  end
end
