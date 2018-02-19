class DropDoctorTable < ActiveRecord::Migration
  def up
    # remove reference from grades
    remove_index :grades, :doctor_id
    remove_column :grades, :doctor_id

    drop_table :doctors
  end

  def down
    create_table :doctors do |t|
      t.string :firstname
      t.string :lastname
      t.string :email

      t.timestamps
    end

    # add back reference to doctors
    add_column :grades, :doctor_id, :integer
    add_index :grades, :doctor_id
  end
end
