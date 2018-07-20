class RepliesController < ApplicationController
  before_action :get_reply, only: [:edit, :update, :destroy]
  respond_to :html, :js

  def notify_watchers(watchers, event_text)
      watchers.each do |watcher_id|
        #Rails.logger.info ' ----    notifying ' + watcher_id.to_s + ' about ' + current_user.id.to_s + ' replying'
        Notification.notify(
          watcher_id,
          current_user.id,
          notifiable: @reply,
          template: 'notifications/_notification_forum_nav',
          event: event_text
        )
      end
  end

  def create
    reply_hash = reply_params
    post_id = reply_hash.delete(:post_id)
    watchers_of_post = []

    @reply = Reply.new(reply_hash)
    @reply.user = current_user

    if @reply.save
      flash[:success] = "Reply was created successfully!"

      # by default create a watcher
      Watcher.create!(
        watchable_type: @reply.class.name,
        watchable_id: @reply.id,
        user: current_user
      )

      # notifications
      event_author = '[See notification] ' + view_context.link_to(current_user.name, user_path(current_user), { :class=>"notif-link" } )
      event_link = ''

      # under special circumstances (when reply is sent to dynamically created reply (if I answer my own answer)) there is no post_id
      if (post_id != '0')
        post = Post.find(post_id)
        event_link = view_context.link_to(post[:title], post_path(post), { :class=>"notif-link" })
        
        # get watchers of the post
        watchers_of_post = Watcher.
          where("watchable_type = ? and watchable_id = ? and user_id != ?", post.class.name, post.id, current_user.id).
          pluck(:user_id)
      else
        event_link = event_author + 'replied in forum'
      end

      # notify watchers of the reply
      watchers = Watcher.
        where("watchable_type = ? and watchable_id = ? and user_id != ?", @reply.replicable_type, @reply.replicable_id, current_user.id).
        pluck(:user_id)

      event_text = event_author + ' replied to you in ' + event_link
      notify_watchers(watchers, event_text)

      watchers.each { |watcher_id| watchers_of_post.delete(watcher_id) }

      # notify watchers of the post
      event_text = event_author + ' replied in post you are watching ' + event_link
      notify_watchers(watchers_of_post, event_text)

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
      :content, :replicable_type, :replicable_id, :parent_reply, :post_id
    )
  end
end
