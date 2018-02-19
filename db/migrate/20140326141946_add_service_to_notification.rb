class AddServiceToNotification < ActiveRecord::Migration
  def up
    change_table :notifications do |t|
      t.remove :type
      t.remove :mist_id

      t.string :receiver
      t.rename :to_send_at, :send_at

      t.references :patient
      t.references :notification_service
    end

    add_index  :notifications, :notification_service_id
    add_index  :notifications, :patient_id
  end

  def down
    remove_index  :notifications, :patient_id
    remove_index  :notifications, :notification_service_id

    change_table :notifications do |t|
      t.remove :receiver
      t.remove :patient_id
      t.remove :notification_service_id

      t.rename :send_at, :to_send_at
      t.string :type
      t.string :mist_id
    end
  end
end
