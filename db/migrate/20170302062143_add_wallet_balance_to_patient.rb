class AddWalletBalanceToPatient < ActiveRecord::Migration
  def change
  	add_column :patients, :wallet_balance, :decimal, precision: 8, scale: 2
  end
end
