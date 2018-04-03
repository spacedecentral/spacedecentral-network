class GDriveFileWorker
  include Sidekiq::Worker

  def perform(file_id,program_id,program_name)
    drive = Google::Apis::DriveV2::DriveService.new

    scope = ['https://www.googleapis.com/auth/drive']

    ENV["GOOGLE_APPLICATION_CREDENTIALS"] = Rails.root.join('spacedecentral-creds.json').to_s
    authorization = Google::Auth.get_application_default(scope)

    auth_client = authorization.dup
    auth_client.sub = 'gsuite@space.coop'
    auth_client.fetch_access_token!
    drive.authorization = auth_client

    # permission.update!({:role=>"reader",:type=>"anyone",:with_link=>true})
    # permission = drive.insert_permission(file_id, permission, email_message: "A New file has been added to the #{mission_name} mission on https://space.coop", send_notification_emails: true, fields: nil, quota_user: nil, user_ip: nil, options: nil)
    program_users = ProgramUserRole.where(:program_id=>program_id)
    logger.info "*** program id - #{program_id}"
    logger.info program_users.inspect
    program_users.each do |u|
      begin
        permission = Google::Apis::DriveV2::Permission.new
        user_role = "reader"
        if u.is_coordinator_or_greater?
          user_role = "writer"
        elsif u.is_designer_or_greater?
          user_role = "writer"
        end 
        logger.info "***U EMAIL #{u.user.email}"
        permission.update!({:email_address=>u.user.email,:value=>u.user.email,:role=>user_role,:type=>"user"})
        permission = drive.insert_permission(file_id, permission, email_message: "A New file has been added to the #{program_name} program on https://spacedecentral.net", send_notification_emails: false, fields: nil, quota_user: nil, user_ip: nil, options: nil)
        logger.info permission.inspect
      rescue Exception => e
        logger.info e.inspect
      end
    end
  end

end

