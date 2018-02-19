class CreateWheneverTasks < ActiveRecord::Migration
  def change
    create_table :whenever_tasks do |t|
      t.string :task
      t.string :meta

      t.timestamps
    end
  end
end
