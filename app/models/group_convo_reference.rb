class GroupConvoReference < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  validates :conversation, presence: true
  validates :user, presence: true

  def self.find_conversation_by_group_size_and_members(group_given, group_size)
    #select_clause = "a.user_id, a.conversation_id, c.id, c.group_size"
    ##new lookup on 1 instance of group_convo_references
    #from_clause = "group_convo_references as a, conversations as c"
    ##join all conversations together
    #where_clause = "a.conversation_id = c.id AND a.user_id IN (#{group_given}) AND c.group_size=#{group_size}"
    #GroupConvoReference.select(select_clause).from(from_clause).where(where_clause).all
    select_clause = "b.user_id, b.conversation_id"
    from_clause = "group_convo_references as a, group_convo_references as b"
    where_clause = "a.conversation_id = b.conversation_id"
    #join all conversations together
    # user 'a' is in the joined conversation
    where_clause += " AND a.user_id IN (#{group_given})"
    # find conversations that either have another member 'b' that would increase the row count beyond the group_given size
    # and also include the single row that will be a=b (if the only rows returned are a=b rows and all 'a's are in group_given)
    # then thats the conversation we are looking for as it has exactly the members in group_given
    where_clause += " AND (b.user_id NOT IN (#{group_given}) OR b.user_id = a.user_id)"
    GroupConvoReference.select(select_clause).from(from_clause).where(where_clause).all
  end

  def send_unread_notification
    @unread = GroupConvoReference.where(:read=>false)
    @unread.each do |convo_user|
      ApplicationMailer.spacedecentral_message_notification(convo_user).deliver    
    end
  end
  
end
