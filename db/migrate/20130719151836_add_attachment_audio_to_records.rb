class AddAttachmentAudioToRecords < ActiveRecord::Migration
  def self.up
    change_table :records do |t|
      t.attachment :audio
    end
  end

  def self.down
    drop_attached_file :records, :audio
  end
end
