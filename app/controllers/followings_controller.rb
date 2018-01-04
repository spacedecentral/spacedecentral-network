class FollowingsController < ApplicationController
  before_action :set_user

  def follow
    current_user.follow(@user)
    event = "<b>#{current_user.name}</b> has followed you."
    Notification.notify(
      params[:id],
      current_user.id,
      event: event
    )
  end

  def unfollow
    current_user.unfollow(@user)
  end

  private

  def set_user
    @user = User.friendly.find(params[:id])
  end
end
