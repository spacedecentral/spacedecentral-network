class ReplyDecorator < ApplicationDecorator
  delegate_all

  def can_modified?
    @can ||= moderators? || mine?
  end

  def mine?
    return false unless h.current_user
    @mine ||= object.user_id == h.current_user.id
  end

  def my_reply?
    object.user_id == object.replicable&.user_id
  end

  def alias
    'comment'
  end
end
