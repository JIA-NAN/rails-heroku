class CreateNotificationSubscriptions < ActiveRecord::Migration
  def change
    create_table :notification_subscriptions do |t|
      t.references :patient
      t.references :notification_service

      t.timestamps
    end
    add_index :notification_subscriptions, :patient_id
    add_index :notification_subscriptions, :notification_service_id
  end
end
