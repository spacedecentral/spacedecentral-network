class AddAttachmentCoverToMissions < ActiveRecord::Migration
  def self.up
    change_table :missions do |t|
      t.attachment :cover
    end
  end

  def self.down
    remove_attachment :missions, :cover
  end
end
