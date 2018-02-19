class AddMetaToRecords < ActiveRecord::Migration
  def change
    add_column :records, :meta, :text
    add_column :records, :pill_time, :integer
  end
end
