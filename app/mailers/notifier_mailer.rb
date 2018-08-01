class NotifierMailer < ActionMailer::Base
  layout 'mailer'

  def notify(n)
    @notifiee = n
    #Rails.logger.info "NotifierMailer called: " + @notifiee.to_s
    mail(
      :to => @notifiee[:email],
      :from => 'noreply@spacedecentral.net',
      :subject => @notifiee[:subject],
    )
  end
end

