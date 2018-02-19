class RemovePillTakenFromRecords < ActiveRecord::Migration
  def up
    remove_column :records, :pill_taken
  end
  def down
    add_column :records, :pill_taken, :string
  end
end
