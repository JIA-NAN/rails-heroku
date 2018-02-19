class AddVideoProcessingToRecord < ActiveRecord::Migration
  def change
    add_column :records, :video_processing, :boolean
  end
end
