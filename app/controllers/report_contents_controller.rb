class ReportContentsController < ApplicationController
  before_action :authenticate_user!

  def new
    @report_content = ReportContent.new(new_params)
  end

  def create
    @report_content = ReportContent.find_or_initialize_by(
      reporter: current_user,
      reportable_id: report_params[:reportable_id]
    )

    if @report_content.persisted?
      @report_content.errors.add(:warning, 'You have already reported')
    else
      @report_content.update(report_params)
    end

    respond_to do |format|
      format.js
    end
  end

  private

  def report_params
    params.require(:report_content).permit(
      :report_type, :reportable_id, :reportable_type,
      :report_parent_type, :report_parent_id
    )
  end

  def new_params
    params.permit(
      :report_type, :reportable_id, :reportable_type,
      :report_parent_type, :report_parent_id
    )
  end

  def valid_class?
    @model = params[:reportable_type].constantize
  rescue StandardError
    false
  end
end
