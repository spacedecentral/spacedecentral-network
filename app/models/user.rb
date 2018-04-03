class User < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged, slug_column: :username

  ROLES = [
    SUPERADMIN    = 1,
    ADMIN         = 2,
    MODERATOR     = 3,
    DEFAULT_USER  = 5
  ].freeze

  USER_ROLE_NAMES =
    {
      ADMIN=>{:name=>'Admin',
        :val=>ADMIN
      },
      MODERATOR=>{:name=>'Moderator',
        :val=>MODERATOR
      },
      DEFAULT_USER=>{:name=>'Default User',
        :val=>DEFAULT_USER
      },
    }.freeze

  attr_accessor :remove_avatar, :remove_cover_photo, :current_password, :step, :new_password

  devise :database_authenticatable, :registerable, :recoverable,
    :rememberable, :trackable, :validatable, :confirmable, :lockable,
    :omniauthable,  omniauth_providers: [:twitter,:facebook,:linkedin,:google_oauth2]

  has_attached_file :avatar,
    styles: {
      large: ["100%", :jpg],
      medium: ["300x300#", :jpg],
      thumb: ["100x100#"]
    },
    :convert_options => {
      medium: "-gravity center -crop '300x300+0+0' -quality 70 -interlace Plane",
      thumb: "-gravity center -crop '100x100+0+0' -quality 70 -interlace Plane",
    },
    :s3_headers => {
      'Cache-Control' => 'max-age=315576000',
      'Expires' => 10.years.from_now.httpdate
    },
    default_url: :default_avatar

  has_attached_file :cover_photo,
    styles: {
      large: "1600x900>",
      medium: "960x540>",
      small: "640x360>"
    },
    :convert_options => {
      :large => "-quality 70 -interlace Plane",
      :medium => "-quality 70 -interlace Plane",
      :small => "-quality 70 -interlace Plane",
    },
    :s3_headers => {
      'Cache-Control' => 'max-age=315576000',
      'Expires' => 10.years.from_now.httpdate
    },
    default_url: "/missing.jpg"

  validates :name, presence: true
  validates :name, format: { with: /\A[a-zA-Z0-9.\s]+\Z/ }, length: { in: 2..40 }#, allow_blank: true, on: :update_profile

  validates :title, presence: true, on: :update_profile
  
  validates_with AttachmentSizeValidator, attributes: :avatar, less_than: 3.megabytes
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/
  validates_attachment_file_name :avatar, matches: [/(png|PNG)\z/, /(jpe|JPE)?(G|g)\Z/]
  validate :given_linkedin_url_must_valid
  validates_with AttachmentSizeValidator, attributes: :cover_photo,
    less_than: 2.megabytes
  validates_attachment_content_type :cover_photo,
    content_type: /\Aimage\/.*\z/
  validates_attachment_file_name :cover_photo,
    matches: [/png\z/, /jpe?g\z/]

  validates :title, :location, presence: true, on: :update_personal
  validates :username,
    presence: true,
    uniqueness: true,
    format: { with: /\A[a-zA-Z0-9.]+\z/ },
    length: { minimum: 5 },
    on: :update_username
  validates :email,
    confirmation: true,
    format: { with: Devise.email_regexp },
    on: :update_email
  validates :new_password, :current_password,
    presence: true,
    length: { minimum: 8, allow_blank: true },
    on: :update_password
  validates :new_password, confirmation: true, on: [:update_email, :update_password]
  validate  :check_valid_current_password, on: [:update_email, :update_password]

  before_validation { avatar.clear if remove_avatar == '1' }
  before_validation { cover_photo.clear if remove_cover_photo == '1' }

  has_many :conversations
  has_many :messages
  has_many :program_user_roles
  has_many :group_convo_references, dependent: :destroy
  has_many :tag_references, dependent: :destroy
  has_many :skills, class_name: Tag, through: :tag_references, source: :tag
  has_many :posts
  has_many :replies, as: :replicable, dependent: :destroy
  has_many :active_relationships, class_name: Following,
                                  foreign_key: :user_id,
                                  dependent: :destroy
  has_many :passive_relationships, class_name: Following,
                                   foreign_key: :follow_user,
                                   dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  has_many :activities, -> {order 'created_at desc'}
  has_many :user_careers, -> { order 'id desc' }
  has_many :user_educations, -> { order 'id desc'}
  has_many :user_publications
  has_many :user_publication_permissions, dependent: :destroy

  accepts_nested_attributes_for :user_careers , reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :user_educations , allow_destroy: true


  def send_on_create_confirmation_instructions
    false
  end

  def confirmation_required?
    false
  end

  def is_suspended_role?
    self.role == 1000
  end

  def active_for_authentication?
    super and !self.is_suspended_role?
  end

  def self.from_omniauth(auth)
    #User.where(:email=> auth.info.email).update_all(:provider=> auth.provider,:uid=>auth.uid,:encrypted_password=>Devise.friendly_token[0,20])
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.encrypted_password = user.password = Devise.friendly_token[0,20]
      user.email = auth.info.email
      user.skip_confirmation!
      # user.name = auth.info.name
    end
  end

  def signup_using_email
    # do validation if user is new record and signup not using provider OR if user already signup keep validate the name
    self.new_record? && self.provider.blank? || self.persisted?
  end

  def get_role_name
    if !self.role.nil? && USER_ROLE_NAMES.has_key?(self.role)
      USER_ROLE_NAMES[self.role][:name]
    elsif is_admin_user?
      USER_ROLE_NAMES[ADMIN][:name]
    else
      "Default User"
    end
  end

  def is_admin_user?
    self.role == ADMIN || self.role == SUPERADMIN
    #!self.role.nil? && self.role < 3
  end

  def moderator?
    self.role == MODERATOR
  end

  def moderator_or_greater?
    !self.role.nil? && self.role <= MODERATOR
  end

  # Follows a user.
  def follow(other_user)
    following << other_user
  end

  # Unfollows a user.
  def unfollow(other_user)
    following.delete(other_user)
  end

  # Returns true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end

  def is_owner_of?(publication)
    return false unless publication
    user_publications.pluck(:user_id).include?(publication.user_id)
  end

  def get_planet_avatar
    planets = ["earth.png", "europa.png", "jupiter.png", "kepler20e.png", "kepler22b.png", "mars.png","mercury.png", "neptune.png", "pluto.png", "saturn.png", "titan.png", "uranus.png", "venus.png"]
    num = id.nil? ? (email.nil? ? 1 : email.size) : id
    File.join(Rails.root, 'app/assets/images/planets', planets[num % planets.length])
  end

  def default_avatar
    text = ""
    if !self.name.nil? && !self.name.empty?
      name_arr = name.split(" ")
      text = name_arr.first.first.upcase
      if name_arr.length > 1
        text << name_arr.last.first.upcase
      end
    end
    image = Magick::Image.read(get_planet_avatar)[0]
    image = image.modulate(brightness=0.8)
    # Draw Text
    drawText = Magick::Draw.new()

    drawText.annotate(image, 0, 0, 0, 2, text) do
      self.pointsize = 50
      self.fill = "#FFFFFF"
      self.gravity = Magick::CenterGravity

    end
    "data:image/png;base64," << Base64.encode64(image.to_blob)
  end

  def given_linkedin_url_must_valid
    if linkedin_url_changed? && !linkedin_url.blank?
      url = linkedin_url
      url = "http://#{url}" if Regexp.new('^www.').match(url) || Regexp.new('^linkedin.').match(url)
      if url =~ /\A#{URI::regexp}\z/
        unless url.include?('linkedin')
          errors.add(:linkedin_url, 'is invalid')
        end
      else
        errors.add(:linkedin_url, 'should begin with http, https, www or linkedin')
      end
    end
  end

  # Nedd this to add https:// to linkedin url
  def full_linkedin_url
    url = linkedin_url
    if Regexp.new('^www.').match(url) || Regexp.new('^linkedin.').match(url)
      "https://#{url}"
    else
      url
    end
  end

  def should_generate_new_friendly_id?
    username.blank?
  end

  def slug_candidates
    [
      name,
      [name, id],
      [name, sequence_username_number]
    ]
  end

  # name = "Bob James 2"
  # similar_usernames = ["bob.james.2", "bobjames.2", "bobjames2"]
  def similar_usernames(string)
    names = []
    string = string.gsub(/\s+/, '.').downcase
    dot_index = string.index('.')
    names << string
    if dot_index.present?
      chars = string.chars
      chars.delete_at(dot_index)
      names << similar_usernames(chars.join)
    end

    names.flatten
  end

  def normalize_friendly_id(string)
    super.downcase.gsub("-", ".")
  end

  def sequence_username_number
    name_generated = self.name.nil? ? self.email.split('@').first.gsub(/\s+/, '.').downcase : self.name.gsub(/\s+/, '.').downcase
    number = User.where("username LIKE ?", "#{name_generated}%").count
    number + 1
  end

  def check_valid_current_password
    return if step.present? || current_password.blank?
    if valid_password?(current_password)
      return self.password = new_password
    end
    errors.add(:current_password, 'is not correct')
  end
end
