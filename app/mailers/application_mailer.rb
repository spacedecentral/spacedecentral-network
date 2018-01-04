class ApplicationMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  before_action :set_environment

  default from: 'info@space.coop'
  layout 'mailer'

  def new_spacedecentral_message(from,to,message)
    @message = message
    @message_date = message["created_at"]&.strftime("%B %e, %Y at %l:%M%p")
    @from = from
    # @to = to
    mail(:to => to.email, :subject =>"New message from #{@from.name} (Space Decentral)", 'Content-Transfer-Encoding'=>"quoted-printable", :content_type => "text/html;")
  end


  def spacedecentral_message_notification(convo_user)
    mail(:to => convo_user.email, :subject =>"You have unread messages on (Space Decentral)", 'Content-Transfer-Encoding'=>"quoted-printable", :content_type => "text/html;")
  end

  private
   def set_environment
       @mailer_environment = "production"
      if Rails.env.staging?
       @mailer_environment = "staging"
      elsif Rails.env.development?
       @mailer_environment = "dev"
      end
   end

end
