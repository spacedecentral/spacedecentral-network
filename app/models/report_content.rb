class ReportContent < ApplicationRecord
  belongs_to :reporter, class_name: User, foreign_key: :user_id
  belongs_to :reportable, polymorphic: true
  belongs_to :report_parent, polymorphic: true

  enum report_type: {
    spam: 1,
    violate_etiquette: 2,
    harassment: 3
  }

  validates :reportable, presence: true

  after_create :send_email_notify_to_moderators

  private

  def send_email_notify_to_moderators
    ReportContentMailer.report(self.id).deliver_later
  end
end
