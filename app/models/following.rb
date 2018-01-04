class Following < ApplicationRecord
  belongs_to :follower, class_name: User, foreign_key: :user_id
  belongs_to :followed, class_name: User, foreign_key: :follow_user

  validates :user_id, presence: true
  validates :follow_user, presence: true

  validates_uniqueness_of  :user_id, scope: :follow_user, :message=>"You are already following this user"
end
