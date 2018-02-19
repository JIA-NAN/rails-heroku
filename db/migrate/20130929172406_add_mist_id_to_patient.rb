class AddMistIdToPatient < ActiveRecord::Migration
  def change
    add_column :patients, :mist_id, :string, default: "", null: false
    add_index :patients, :mist_id
  end
end
