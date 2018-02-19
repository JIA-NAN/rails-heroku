class CreateAutoGrades < ActiveRecord::Migration
  def change
    create_table :auto_grades do |t|
      t.boolean :is_face_recognized
      t.float :face_recognition_score
      t.boolean :is_pill_taken

      t.timestamps
    end
  end
end
