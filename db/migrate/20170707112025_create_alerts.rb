class CreateAlerts < ActiveRecord::Migration
  def change
    create_table :alerts do |t|
      t.integer :time_start
      t.integer :time_repeat
      t.string :text

      t.timestamps
    end
  end
end
