class AddPhoneToPatient < ActiveRecord::Migration
  def change
    add_column :patients, :phone, :string
  end
end
