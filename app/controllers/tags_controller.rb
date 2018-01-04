class TagsController < ApplicationController

  skip_before_filter :set_messages
  skip_before_filter :set_notifications
  skip_before_filter :set_global_user
  
  def index
    term = params["term"]
    if !term.nil?
      @tags = Tag.where("tag LIKE ?", "%"+term+"%", )
    end
    Rails.logger.info @tags.inspect

    respond_to do |format|
      format.html
      format.json
    end
  end

end