require 'yaml'

class ReportContentMailer < ApplicationMailer
  def report(report_id)
    @report = ReportContent.find_by(id: report_id)
    return unless @report

    mail(to: moderators_emails, subject: 'Report Content')
  end

  def moderators_emails
    @emails ||= User.where("role IN (?)", [User::ADMIN, User::MODERATOR])
  end
end
