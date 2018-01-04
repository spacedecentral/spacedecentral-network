class Contact < ApplicationRecord
  validates :name, :email, :message, presence: true

  validates :email,
    format: {
      with: Devise.email_regexp,
      allow_blank: true
    }
end
