class GDriveFile < ApplicationRecord
  before_save :check_membership, acceptance: { message: 'You need to be a member before you can share files' }

  belongs_to :user
  belongs_to :program

  validates :program, presence: true
  validates :user, presence: true
  validates :title, presence: true
  validates :direct_link, presence: true

end
