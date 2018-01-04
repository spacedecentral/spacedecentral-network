class ContactMailer < ApplicationMailer
  def contact(id)
    @contact = Contact.find_by(id: id)
    return unless @contact

    subject = @contact.subject.blank? ? "[Contact] From #{@contact.name}" : @contact.subject
    mail(to: 'curious@space.coop', subject: subject)
  end
end
