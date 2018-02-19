class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :mist_id
      t.string :message
      t.string :type
      t.boolean :sent, default: false
      t.datetime :to_send_at

      t.timestamps
    end

    add_index :notifications, :mist_id
  end
end
