class PostDecorator < ApplicationDecorator
  delegate_all

  def can_modified?
    @can ||= moderators? || mine?
  end

  def can_pin?
    @can ||= moderators?
  end

  def mine?
    return false unless h.current_user
    @mine ||= object.user_id == h.current_user.id
  end

  def tags_chip
    object.tags.map do |tag|
      { label: tag.tag, id: tag.id }
    end.to_json
  end

  def label
    return 'general' if object.general?
    @label ||= object.postable&.name.to_s
  end

  def cover_url
    object.postable&.cover&.url if object.mission? || object.project?
  end
end
