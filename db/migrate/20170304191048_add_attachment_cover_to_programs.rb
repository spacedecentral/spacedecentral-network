class AddAttachmentCoverToPrograms < ActiveRecord::Migration
  def self.up
    change_table :programs do |t|
      t.attachment :cover
    end
  end

  def self.down
    remove_attachment :programs, :cover
  end
end
