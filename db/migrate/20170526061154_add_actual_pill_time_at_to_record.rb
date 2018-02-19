class AddActualPillTimeAtToRecord < ActiveRecord::Migration
  def change

  	add_column :records, :actual_pill_time_at, :datetime


  end
end
