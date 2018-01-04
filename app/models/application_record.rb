class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  
  def check_membership
    ismember = MissionUserRole.where(:user_id=>self.user.id, :mission_id=>self.mission_id).exists?
    if ismember
      true
    else
      false
    end
  end
end
