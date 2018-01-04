class Reply < ApplicationRecord
  belongs_to :user
  belongs_to :replicable, polymorphic: true, counter_cache: true
  has_many :replies, as: :replicable, dependent: :destroy
  has_many :likes, as: :likable, dependent: :destroy
end
