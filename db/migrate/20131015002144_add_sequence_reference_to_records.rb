class AddSequenceReferenceToRecords < ActiveRecord::Migration
  def change
    add_column :records, :pill_sequence_id, :integer
    add_index :records, :pill_sequence_id
  end
end
