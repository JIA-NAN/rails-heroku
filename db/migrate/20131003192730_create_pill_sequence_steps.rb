class CreatePillSequenceSteps < ActiveRecord::Migration
  def change
    create_table :pill_sequence_steps do |t|
      t.string :name
      t.integer :step_no
      t.string :meta
      t.references :pill_sequence

      t.timestamps
    end

    add_index :pill_sequence_steps, :pill_sequence_id
  end
end
