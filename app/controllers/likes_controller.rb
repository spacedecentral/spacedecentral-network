class LikesController < ApplicationController
  before_action :authenticate_user!

  respond_to :js

  def create
    @like = Like.find_or_initialize_by(
      likable_id: params[:likable_id],
      likable_type: params[:likable_type],
      user_id: current_user.id
    )
    @like.toggle
  end

  private

  def like_params
    params.permit(:likable_id, :likable_type)
  end
end
