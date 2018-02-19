class AddRecordToAutoGrade < ActiveRecord::Migration
  def change
    add_column :auto_grades, :record_id, :integer
    add_index :auto_grades, :record_id
  end
end
