class Post < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  enum post_type: {
    general: 0,
    program: 1,
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

  def total_replies_count(msg = self)
    total_count = msg.replies_count
    if msg.replies_count > 0
      msg.replies.each do |sub_reply|
        total_count += total_replies_count(sub_reply)
      end
    end
    return total_count
  end

  private

  def assign_post_type
    return unless postable.present?
    self.post_type = postable.program_type? ? :program : :project
  end
end
