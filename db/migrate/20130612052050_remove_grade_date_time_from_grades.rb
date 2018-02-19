class RemoveGradeDateTimeFromGrades < ActiveRecord::Migration
  def up
    remove_column :grades, :gradeDateTime
  end

  def down
    add_column :grades, :gradeDateTime, :datetime
  end
end
