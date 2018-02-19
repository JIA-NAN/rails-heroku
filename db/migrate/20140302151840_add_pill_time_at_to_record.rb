class AddPillTimeAtToRecord < ActiveRecord::Migration
  def up
    # remove pill_time because it holds too little information
    remove_column :records, :pill_time

    # add pill_time_at with index
    add_column :records, :pill_time_at, :datetime
    add_index :records, :pill_time_at

    # init pill_time_at for existing records
    Record.find_each do |record|
      record.update_attributes(pill_time_at: record.created_at);
    end
  end

  def down
    # remove pill_time_at
    remove_index :records, :pill_time_at
    remove_column :records, :pill_time_at

    # add back pill_time
    add_column :records, :pill_time, :integer
  end
end
