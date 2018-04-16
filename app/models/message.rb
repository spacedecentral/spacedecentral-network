class Message < ApplicationRecord
  after_create :message_notification
  belongs_to :conversation
  belongs_to :user

  validates :user, :body, presence: true
  validate :user_to_or_conversation

  def get_user_to
    User.where(:id=>self.user_to)
  end

  def message_notification
    # if !self.user_to.nil?
    #   fromUser = User.find(self.user_id)
    #   toUser = User.find(self.user_to)
    #   ApplicationMailer.new_spacedecentral_message(fromUser,toUser,self).deliver
    # end
  end


  def archive_chats
    oldchats = Message.where("program_id NOT NULL AND user_to IS NULL AND created_at < ?", (DateTime.now-2.days))
    #TODO add smarter logic to archive chats maybe highlight important summary objects
    # highlight high active topics or liked comments etc...
    # for now just delete old chats
    oldchats.destroy_all  
  end

  private
    def user_to_or_conversation
      if self.user_to.blank? && self.conversation_id.blank? && self.program_id.blank?
        errors.add(:base, "Message needs to be sent to a user or a group")
      end
    end

end
