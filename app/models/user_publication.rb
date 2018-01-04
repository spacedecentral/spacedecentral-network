class UserPublication < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  attr_accessor :is_clear_paper_file
  serialize :additional_authors, Array

  belongs_to :user
  has_many :tag_references, dependent: :destroy
  has_many :tags, through: :tag_references
  has_many :publication_authors, dependent: :destroy
  has_many :authors, through: :publication_authors, source: :user
  has_many :publication_long_lats, dependent: :destroy
  has_many :likes, as: :likable, dependent: :destroy
  has_many :replies, as: :replicable, dependent: :destroy
  has_many :user_publication_permissions, dependent: :destroy

  has_attached_file :paper, default_url: "/404.html"

  validates :user, presence: true
  validates_with AttachmentSizeValidator,
    attributes: :paper, less_than: 20.megabytes
  validates_attachment :paper,
    content_type: {
      content_type: [
        "application/x-latex",
        "application/x-tex",
        "application/pdf",
        "application/msword",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      ]
  }
  validates_attachment_file_name :paper, matches: [/pdf\z/, /docx?\z/, /tex\z/]
  validates :publication_url, url: { allow_blank: true }
  validates :title, presence: true
  validates :title, :doi, :publisher,
            :volume, :issue, :arXiv,
            length: { in: 0..255, message: 'is too long (255 characters max)' },
            allow_blank: true
  validates :PMID, numericality: true, allow_blank: true

  accepts_nested_attributes_for :publication_long_lats,
    reject_if: :all_blank, allow_destroy: true

  before_save :destroy_paper

  def additional_authors
    self[:additional_authors] || []
  end

  def additional_authors=value
    value ||= []
    if value.is_a?(String)
      value = value.to_s.split(',').map(&:strip).reject(&:empty?).map(&:downcase).uniq
    end

    self[:additional_authors] = value
  end

  def find_or_create_permission_request_for(requester)
    request = user_publication_permissions
      .where(status: [:approved, :requested]).first

    if request.blank? || (request && request.persisted? && request.denied?)
      request = user_publication_permissions.create(requester: requester)
    end

    request
  end

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

  def destroy_paper
    paper.clear if is_clear_paper_file.to_b
  end
end
