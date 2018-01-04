class UserCareer < ApplicationRecord
  belongs_to :user


  validates :position, presence: true
  validates :company, presence: true
end
