class Conversation < ApplicationRecord
  belongs_to :message

  def self.get_convo_messages(convo_id)
    query = "SELECT m.user_id AS user_id, m.body AS body, m.created_at AS created_at, "
    query += " u.id AS u_id, u.email AS u_email, u.name AS u_name, u.avatar_file_name AS u_avatar_file_name, u.avatar_content_type AS u_avatar_content_type "
    query += " FROM messages as m, users as u "
    query += " WHERE m.user_id = u.id AND m.conversation_id = #{convo_id}"
    query += " ORDER BY m.created_at "
    ActiveRecord::Base.connection.select_all(query).to_hash
  end
end
