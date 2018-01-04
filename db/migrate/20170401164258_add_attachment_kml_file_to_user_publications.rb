class AddAttachmentKmlFileToUserPublications < ActiveRecord::Migration
  def self.up
    change_table :user_publications do |t|
      t.attachment :kml_file
    end
  end

  def self.down
    remove_attachment :user_publications, :kml_file
  end
end
