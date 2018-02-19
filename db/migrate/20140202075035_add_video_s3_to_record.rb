class AddVideoS3ToRecord < ActiveRecord::Migration
  def self.up
    change_table :records do |t|
      t.attachment :video_s3
    end
  end

  def self.down
    drop_attached_file :records, :video_s3
  end
end
