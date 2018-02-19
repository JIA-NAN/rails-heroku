class CreateGrades < ActiveRecord::Migration
  def change
    create_table :grades do |t|
      t.datetime :gradeDateTime
      t.string :grade
      t.text :comment
      t.references :doctor
      t.references :record

      t.timestamps
    end
    add_index :grades, :doctor_id
    add_index :grades, :record_id
  end
end
