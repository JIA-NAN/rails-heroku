class RemoveSubmitDateTimeFromRecords < ActiveRecord::Migration
  def up
    remove_column :records, :submitDateTime
  end

  def down
    add_column :records, :submitDateTime, :datetime
  end
end
