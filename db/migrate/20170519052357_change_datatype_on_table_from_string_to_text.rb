class ChangeDatatypeOnTableFromStringToText < ActiveRecord::Migration
  def change
    change_column :records, :screenshot_urls, :text, :limit => nil
    change_column :records, :meta_steplized, :text, :limit => nil
    change_column :records, :video_steplized_content_type, :text, :limit => nil
    change_column :records, :video_steplized_file_size, :text, :limit => nil
    change_column :records, :video_s3_file_name, :text, :limit => nil
    change_column :records, :status, :text, :limit => nil

  end	
  def up
  end

  def down
  end
end
