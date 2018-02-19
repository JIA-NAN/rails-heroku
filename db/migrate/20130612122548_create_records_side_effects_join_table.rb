class CreateRecordsSideEffectsJoinTable < ActiveRecord::Migration
  def change
    create_table :records_side_effects, :id => false do |t|
        t.references :record
        t.references :side_effect
    end
    add_index :records_side_effects, [:record_id, :side_effect_id]
  end
end
