class Program < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  enum object_type: {
    program: 1,
    project: 2
  }, _suffix: :type

  has_attached_file :cover,
    styles: {
      large: ["1600x900>", :jpg],
      medium: ["960x540>", :jpg],
      thumb: ["320x180", :jpg]
    },
    :convert_options => {
      :large => "-quality 70 -interlace Plane",
      :medium => "-quality 70 -interlace Plane",
      :thumb => "-quality 70 -interlace Plane",
    },
    :s3_headers => {
      'Cache-Control' => 'max-age=315576000',
      'Expires' => 10.years.from_now.httpdate
    }, default_url: "/missing.jpg"

  attr_accessor :remove_cover
  before_validation { cover.clear if remove_cover == '1' }

  validates :name, presence: true
  validates :description, presence: true
  validates :parent, presence: true, if: :create_project?
  validates_with AttachmentSizeValidator, attributes: :cover, less_than: 3.megabytes
  validates_attachment_content_type :cover, content_type: /\Aimage\/.*\z/
  validates_attachment_file_name :cover, matches: [/png\z/, /jpe?g\z/]

  has_many :program_user_roles, dependent: :destroy
  has_many :users, through: :program_user_roles
  has_many :posts, as: :postable, dependent: :destroy
  belongs_to :dad, class_name: Program, foreign_key: :parent

  def projects
    @projects ||= Program.project_type.where(parent: self.id)
  end

  def slug_candidates
    [
      :name,
      [:name, :id],
      [:name, "#{SecureRandom.hex(4)}"]
    ]
  end

  def should_generate_new_friendly_id?
    slug.blank? || name_changed?
  end

  private

  def create_project?
    self.project_type?
  end
end
