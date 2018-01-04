class TagReference < ApplicationRecord
  belongs_to :tag
  belongs_to :post
  belongs_to :user_publication
  belongs_to :user

  validates :tag, presence: true
end
