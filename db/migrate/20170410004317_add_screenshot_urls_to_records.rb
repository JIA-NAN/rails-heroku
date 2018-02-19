class AddScreenshotUrlsToRecords < ActiveRecord::Migration
  def change
    add_column :records, :screenshot_urls, :string
  end
end
