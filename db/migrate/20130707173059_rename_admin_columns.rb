class RenameAdminColumns < ActiveRecord::Migration

  def change
    change_table :admins do |t|
      t.rename :first_name, :firstname
      t.rename :last_name, :lastname
    end
  end

end
