class EnableTokenAuthenticationToPatient < ActiveRecord::Migration
  def change
    change_table :patients do |t|
      ## Token authenticatable
      t.string :authentication_token
    end

    add_index :patients, :authentication_token, :unique => true
  end
end
