class AttachmentsController < ActionController::Base
  protect_from_forgery with: :null_session

  def upload
    attachment = params[:files][0]
    uploader = Editor::Uploader.new(attachment)
    uploader.execute

    if uploader.success
      render json: { path: uploader.path, title: attachment.original_filename }
    else
      render json: { error: uploader.error }
    end
  end
end
