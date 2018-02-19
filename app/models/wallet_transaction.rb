class WalletTransaction < ActiveRecord::Base
  belongs_to :patient
  attr_accessible :amount, :time
end
