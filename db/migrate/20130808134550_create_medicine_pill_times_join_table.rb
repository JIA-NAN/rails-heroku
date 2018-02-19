class CreateMedicinePillTimesJoinTable < ActiveRecord::Migration
  def change
    create_table :medicines_pill_times, :id => false do |t|
        t.references :medicine
        t.references :pill_time
    end
    add_index :medicines_pill_times, [:medicine_id, :pill_time_id]
  end
end
