class RepliesController < ApplicationController
  before_action :get_reply, only: [:edit, :update, :destroy]
  respond_to :html, :js

  def notify_watcher(watcher_id, event_text, linkage)
    #Rails.logger.info ' ----    notifying ' + watcher_id.to_s + ' about ' + current_user.id.to_s + ' replying'
    Notification.notify(
      watcher_id,
      current_user.id,
      notifiable: @reply,
      template: 'notifications/_notification_forum_nav',
      event: event_text,
      linkage: linkage
    )
  end

  def create
    reply_hash = reply_params
    post_id = reply_hash.delete(:post_id)
    watchers_of_post = []

    @reply = Reply.new(reply_hash)
    @reply.user = current_user

    if @reply.save
      flash[:success] = "Reply was created successfully!"

      # notifications
      event_author = view_context.link_to('@' + current_user.name, "#{request.base_url}" + user_path(current_user), { :class=>"notif-link" } )
      event_link = ''
      event_text = ''
      event_source = ''

      # under special circumstances (when reply is sent to dynamically created reply (if I answer my own answer)) there is no post_id
      if (post_id != '0')
        post = Post.find(post_id)

        # by default create a watcher for post (not just reply)
        Watcher.find_or_create_by(
          watchable_type: post.class.name,
          watchable_id: post.id,
          user: current_user
        )

        # it might be a reply to a reply...
        parent_reply = @reply.replicable_type == 'Reply' ? Reply.find(@reply.replicable_id) : nil
        
        # event source should be direct link to reply
        event_source = "#{request.base_url}" + post_path(post)
        event_link = view_context.link_to(post[:title], event_source, { :class=>"notif-link" })

        # get watchers of the post other than the author
        watchers_of_post = Watcher.
          where("watchable_type = ? and watchable_id = ? and user_id != ?", post.class.name, post.id, current_user.id).
          pluck(:user_id)

        watchers_of_post.each do |watcher_id|
          # only people watching thread get notified.
          if @reply.replicable_type == post.class.name
            # cases: 1. someone responds to my post
            if watcher_id == post.user_id
              event_text = event_author + ' replied to your post: ' + event_link
            # cases: 2. someone responds to post I'm watching
            else
              event_text = event_author + ' replied in post you are watching: ' + event_link
            end
          else
            # cases: 3. someone responds to my reply in a post I'm watching
            if watcher_id == parent_reply.user_id
              event_text = event_author + ' replied to you in post: ' + event_link
            else
              event_text = event_author + ' replied in post you are watching: ' + event_link
            end
          end

          notify_watcher(watcher_id, event_text, event_source)
        end
      end
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
