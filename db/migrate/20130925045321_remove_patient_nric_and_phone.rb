class RemovePatientNricAndPhone < ActiveRecord::Migration
  def up
    remove_column :patients, :nric
    remove_column :patients, :phone
  end

  def down
    add_column :patients, :nric, :string, :null => false
    add_column :patients, :phone, :string, :null => false
  end
end
