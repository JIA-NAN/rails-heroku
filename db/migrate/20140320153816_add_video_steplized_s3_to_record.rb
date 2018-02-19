class AddVideoSteplizedS3ToRecord < ActiveRecord::Migration
  def self.up
    change_table :records do |t|
      t.attachment :video_steplized
    end
  end

  def self.down
    drop_attached_file :records, :video_steplized
  end
end
