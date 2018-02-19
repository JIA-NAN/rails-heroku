class CreateWalletTransactions < ActiveRecord::Migration
  def change
    create_table :wallet_transactions do |t|
      t.references :patient
      t.decimal :amount, :precision => 8, :scale => 2
      t.datetime :time

      t.timestamps
    end
    add_index :wallet_transactions, :patient_id
  end
end
