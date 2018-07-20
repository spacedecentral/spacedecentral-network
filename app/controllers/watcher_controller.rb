class WatcherController < ApplicationController
  before_action :authenticate_user!

  respond_to :js

  def create
    @watcher = Watcher.find_or_initialize_by(
      watchable_id: params[:watchable_id],
      watchable_type: params[:watchable_type],
      user_id: current_user.id
    )
    @watcher.toggle
  end

  private

  def watcher_params
    params.permit(:watchable_id, :watchable_type)
  end
end

