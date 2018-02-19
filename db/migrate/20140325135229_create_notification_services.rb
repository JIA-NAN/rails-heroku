class CreateNotificationServices < ActiveRecord::Migration
  def change
    create_table :notification_services do |t|
      t.string :name
      t.string :service

      t.timestamps
    end
  end
end
