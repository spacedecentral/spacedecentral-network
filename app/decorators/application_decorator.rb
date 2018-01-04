class ApplicationDecorator < Draper::Decorator
  def alias
    object.class.name
  end

  def moderators?
    @moderators ||= h.user_signed_in? && (h.current_user.moderator_or_greater?)
  end
end
