class AddReportToRecord < ActiveRecord::Migration
  def change
    add_column :records, :report, :integer
  end
end
