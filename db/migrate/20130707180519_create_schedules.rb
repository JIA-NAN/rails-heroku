class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.date :started_at
      t.date :terminated_at

      t.references :patient
      t.timestamps
    end

    add_index :schedules, :patient_id
  end
end
