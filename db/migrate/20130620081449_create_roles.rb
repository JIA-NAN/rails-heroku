class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name, :null => false, :default => "User"
      t.text :description

      t.timestamps
    end
  end
end
