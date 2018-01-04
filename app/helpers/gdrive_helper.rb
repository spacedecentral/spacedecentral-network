module GdriveHelper


  def format_gdrive_timestamp(gdrive_dt)
    if !gdrive_dt.nil?
      dt = DateTime.parse(gdrive_dt.to_s)
      if !dt.nil?
        return platform_timestamp(dt)
      end
    end
    return ""
  end
  
end
