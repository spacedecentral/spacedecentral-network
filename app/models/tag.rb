class Tag < ApplicationRecord
  has_many :tag_references, dependent: :destroy
  has_many :posts, through: :tag_references

  validates :tag, presence: true
  validates_uniqueness_of :tag, :on => :create
end
