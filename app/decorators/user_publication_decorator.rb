class UserPublicationDecorator < ApplicationDecorator
  delegate_all

  def current_user_has_permission?
    return false unless h.user_signed_in?
    return true if h.current_user.is_owner_of?(object)

    @permission ||= object.user_publication_permissions.approved.exists?(
      requester: h.current_user)
  end

  def can_edit_delete?
    h.user_signed_in? && h.current_user.id == object.user_id
  end

  def mine?
    return false unless h.current_user
    object.user_id == h.current_user.id
  end

  def my_reply?
    object.user_id == object.replicable&.user_id
  end

  def public_date_format
    return if object.publication_date.blank?
    object.publication_date.strftime('%B %Y')
  end

  def requested?
    h.user_signed_in? && h.current_user.user_publication_permissions.requested.pluck(:user_publication_id).include?(object.id)
  end

  def alias
    'publication'
  end

  def authors_chip
    authors = object.authors

    authors = authors.map do |author|
      {
        id: author.id,
        avatar: author.avatar.try(:url, :thumb),
        label: author.name,
      }
    end

    object.additional_authors.each do |additional_author|
      authors << { label: additional_author }
    end

    if h.user_signed_in? && authors.find {|x| x[:id] == h.current_user.id }.blank?
      authors = authors.unshift({
        id: h.current_user.id,
        label: h.current_user.name,
        avatar: h.current_user.avatar.url,
        notRemove: true
      })
    end

    authors.compact.to_json
  end

  def tags_chip
    object.tags.map do |tag|
      {
        label: tag.tag,
        id: tag.id
      }
    end.to_json
  end

  def get_authors
    object.authors.pluck(:name) + object.additional_authors
  end
end
