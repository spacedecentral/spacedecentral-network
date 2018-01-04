class PublicationLongLat < ApplicationRecord
  belongs_to :user_publication

  validates :longitude, presence: true
  validates :latitude, presence: true


end
