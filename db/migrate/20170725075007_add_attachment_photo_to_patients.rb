class AddAttachmentPhotoToPatients < ActiveRecord::Migration
  def self.up
    change_table :patients do |t|
      t.attachment :photo
    end
  end

  def self.down
    drop_attached_file :patients, :photo
  end
end
