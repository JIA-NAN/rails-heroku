class AddMetaSteplizedToRecord < ActiveRecord::Migration
  def up
    add_column :records, :meta_steplized, :string

    Record.where("video_steplized_file_name IS NOT NULL").each do |record|
      meta = []
      record.steps.inject(0) { |p, c| (meta << p + c).last }

      record.meta_steplized = meta.join(",")
      record.meta = meta.join(",")
      record.save!
    end
  end

  def down
    remove_column :records, :meta_steplized
  end
end
