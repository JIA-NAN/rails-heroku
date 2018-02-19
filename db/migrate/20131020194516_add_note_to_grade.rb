class AddNoteToGrade < ActiveRecord::Migration
  def change
    add_column :grades, :note, :text
  end
end
