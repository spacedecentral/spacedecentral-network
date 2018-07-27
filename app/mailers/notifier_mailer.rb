class NotifierMailer < ApplicationMailer
  def notify()

#@notifiee = {:name => 'RKZ', :email => 'rkz@Hyperlogos.net', :message => 'insignificant message received'}

    Rails.logger.info "- - -- - -- NotifierMailer called: " + @notifiee.to_s
    
    mail(
      :to => @notifiee.email,
      :from => 'qinfo@space.coop',
      :subject => @notifiee.subject,
      'Content-Transfer-Encoding' => "quoted-printable",
      :content_type => "text/html;"
  )

  end
end

