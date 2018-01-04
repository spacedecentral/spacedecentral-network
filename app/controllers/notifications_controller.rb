class NotificationsController < ApplicationController
  before_action :set_notification, only: [:show, :edit, :update, :destroy]

  # GET /notifications
  # GET /notifications.json
  def index
    @notifications = Notification.where(user_id: current_user.id)
    mark_as_read(@notifications)
    @notifications.reload
  end

  # GET /notifications/1
  # GET /notifications/1.json
  def show
    begin
      if !@notification.read
        begin
          ActionCable.server.broadcast "app_notifier_#{@notification.user_id}", decrement_notification_unread: 1
        rescue Exception => e
          Rails.logger.info e.inspect
        end
      end
      @notification.read = true
      @notification.save
      Rails.logger.info "Marked notification as read"
    rescue
    end
  end

  # DELETE /notifications/1
  # DELETE /notifications/1.json
  def destroy
    @notification.destroy
    respond_to do |format|
      format.html { redirect_to notifications_url, notice: 'Notification was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_notification
      @notification = Notification.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def notification_params
      params.fetch(:notification, {})
    end

    def mark_as_read(notifications)
      notifications.update_all(read: true) if notifications.present?
    end
end
