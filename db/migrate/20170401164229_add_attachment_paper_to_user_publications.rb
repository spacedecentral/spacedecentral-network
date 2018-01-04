class AddAttachmentPaperToUserPublications < ActiveRecord::Migration
  def self.up
    change_table :user_publications do |t|
      t.attachment :paper
    end
  end

  def self.down
    remove_attachment :user_publications, :paper
  end
end
