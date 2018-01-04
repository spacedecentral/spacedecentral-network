module ConversationsHelper

  def get_other_group_members(json, current_user_id)
    us = User.joins(:group_convo_references).where.not(:id=>current_user_id).where(:group_convo_references=>{:conversation_id=>json["c_id"]})
    Rails.logger.info us.inspect
    us
  end

  # i dont see any easy way to get the avatar wihout having direct access to a user model 
  # and use raw sql results to load users doesnt load the models when joined
  # so this takes in the raw json join and creates a temp user but doesnt save it
  def raw_avatar_helper(json)
    u = User.new
    u.avatar_file_name = json["u_avatar_file_name"]
    u.avatar_content_type = json["u_avatar_content_type"]
    u.email = json["u_email"]
    u.id = json["u_id"]
    u.name = json["u_name"]    
    # json["u_avatar_file_name"].empty? ? u.get_planet_avatar : u
    u
  end
    
end
