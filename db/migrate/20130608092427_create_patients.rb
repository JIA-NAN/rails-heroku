class CreatePatients < ActiveRecord::Migration
  def change
    create_table :patients do |t|
      t.string :firstname, :null => false
      t.string :lastname, :null => false
      t.string :phone, :null => false
      t.string :nric, :null => false

      t.timestamps
    end
    add_index :patients, :nric, :unique => true
  end
end
