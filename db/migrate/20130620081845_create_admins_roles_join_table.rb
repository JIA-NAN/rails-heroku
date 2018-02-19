class CreateAdminsRolesJoinTable < ActiveRecord::Migration
  def change
    create_table :admins_roles, :id => false do |t|
        t.references :admin
        t.references :role
    end

    add_index :admins_roles, [:admin_id, :role_id]
  end
end
