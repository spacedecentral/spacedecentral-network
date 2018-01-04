class ContactsController < ActionController::Base
  def create
    @contact = Contact.new(contact_params)
    if @contact.save
      ContactMailer.contact(@contact.id).deliver_now
      @contact = Contact.new
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :email, :subject, :message)
  end
end
