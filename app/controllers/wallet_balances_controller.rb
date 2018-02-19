class WalletBalancesController < ApplicationController
  before_filter :authenticate_admin!, except: [:show]
  before_filter :authenticate_patient!, except: [:index]

  def index
    @wallet_balances = WalletBalance.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @wallet_balances }
    end
  end

  def show
    #@wallet_balance = WalletBalance.where(patient_id: current_patient.id)
    current_patient.update_wallet
    @wallet_balance = current_patient.wallet_balance
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: { patient_id: current_patient.id,
        balance: @wallet_balance }}
    end
  end
end
