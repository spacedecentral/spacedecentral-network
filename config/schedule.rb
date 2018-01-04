# Use this file to easily define all of your cron jobs.

# Learn more: http://github.com/javan/whenever

env 'MAILTO', 'dennis@space.coop'

# every 2.days do
#   runner "Message.archive_chats"
# end


every 1.days do
  runner "GroupConvoReference.send_unread_notification"
end