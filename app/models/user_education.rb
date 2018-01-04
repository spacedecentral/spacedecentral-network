class UserEducation < ApplicationRecord
  belongs_to :user

  validates :degree, presence: true
  validates :school, presence: true
end
