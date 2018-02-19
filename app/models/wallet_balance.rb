# See https://rietta.com/blog/2013/11/28/rails-and-sql-views-for-a-report/
# This is a read-only model based on a database view

# == Schema Information
#
# Table name: wallet_balances
#
#  id         :integer
#  patient_id :integer
#  balance    :decimal
#
class WalletBalance < ActiveRecord::Base
  belongs_to :patient
  self.table_name = 'wallet_balances'

  def readonly?
    true
  end
end
