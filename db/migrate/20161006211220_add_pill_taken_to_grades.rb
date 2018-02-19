class AddPillTakenToGrades < ActiveRecord::Migration
  def change
	add_column :grades, :pill_taken, :string
  end
end
