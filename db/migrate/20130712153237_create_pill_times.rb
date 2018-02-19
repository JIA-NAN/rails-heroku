class CreatePillTimes < ActiveRecord::Migration
  def change
    create_table :pill_times do |t|
      t.integer :monday
      t.integer :tuesday
      t.integer :wednesday
      t.integer :thursday
      t.integer :friday
      t.integer :saturday
      t.integer :sunday

      t.references :schedule
      t.timestamps
    end

    add_index :pill_times, :schedule_id
  end
end
