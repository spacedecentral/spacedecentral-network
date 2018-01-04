class PublicationAuthor < ApplicationRecord
  belongs_to :user_publication
  belongs_to :user

  validates :author, presence: true
  validates :user_publication, presence: true

  before_validation :assign_author_name

  private

  def assign_author_name
    self.author = user&.name
  end
end
