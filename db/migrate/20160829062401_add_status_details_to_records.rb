class AddStatusDetailsToRecords < ActiveRecord::Migration
  def change
    add_column :records, :received, :boolean
    add_column :records, :graded, :boolean
    add_column :records, :pill_taken, :string
    add_column :records, :explained, :string
    add_column :records, :explanation, :string
  end
end
