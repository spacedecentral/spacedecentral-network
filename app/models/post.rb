class Post < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  enum post_type: {
    general: 0,
    mission: 1,
    project: 2
  }

  belongs_to :user
  belongs_to :postable, polymorphic: true

  has_many :replies, as: :replicable, dependent: :destroy
  has_many :likes, as: :likable, dependent: :destroy
  has_many :tag_references, dependent: :destroy
  has_many :tags, through: :tag_references

  validates :title,
            presence: true,
            length: { in: 0..255, allow_blank: true }

  before_save :assign_post_type

  def slug_candidates
    [
      :title,
      [:title, :id],
      [:title, "#{SecureRandom.hex(4)}"]
    ]
  end

  def should_generate_new_friendly_id?
    slug.blank? || title_changed?
  end

  private

  def assign_post_type
    return unless postable.present?
    self.post_type = postable.mission_type? ? :mission : :project
  end
end
