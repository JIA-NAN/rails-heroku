class AddExplanationToGrades < ActiveRecord::Migration
  def change
	add_column :grades, :explanation, :string
  end
end
