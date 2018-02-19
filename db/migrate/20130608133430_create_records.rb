class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
      t.datetime :submitDateTime
      t.string :device, :default => 'unknown device'
      t.text :comment
      t.string :status, :default => 'pending'
      t.references :patient

      t.timestamps
    end
    add_index :records, :patient_id
  end
end
