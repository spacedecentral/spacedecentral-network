class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  
  def check_membership
    ismember = ProgramUserRole.where(:user_id=>self.user.id, :program_id=>self.program_id).exists?
    if ismember
      true
    else
      false
    end
  end
end
