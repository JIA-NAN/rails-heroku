class RemoveExplainedFromRecords < ActiveRecord::Migration
  def up
    remove_column :records, :explained
    remove_column :records, :explanation
  end
  def down
    add_column :records, :explained, :string
    add_column :records, :explanation, :string
  end
end
