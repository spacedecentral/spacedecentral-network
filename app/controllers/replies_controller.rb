class RepliesController < ApplicationController
  before_action :get_reply, only: [:edit, :update, :destroy]
  respond_to :html, :js

  def create
    @reply = Reply.new(reply_params)
    @reply.user = current_user

    if @reply.save
      flash[:success] = "Reply was created successfully!"
    else
      flash[:error] = "Sorry! some errors."
    end
  end

  def edit; end

  def update
    if @reply.update(reply_params)
      flash[:success] = "Reply was created successfully!"
    else
      flash[:error] = "Sorry! some errors."
    end
  end

  def destroy
    if @reply.destroy
      flash[:success] = "Reply was deleted successfully!"
    else
      flash[:error] = "Reply could not be deleted"
    end
  end

  private

  def get_reply
    @reply = Reply.find_by(id: params[:id])
  end

  def reply_params
    params.require(:reply).permit(
      :content, :replicable_type, :replicable_id, :parent_reply
    )
  end
end
