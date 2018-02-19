class WalletTransactionsController < ApplicationController
  before_filter :authenticate_admin!


  before_filter :set_patient, only: [:index, :new, :create, :show, :edit, :update, :destroy]
  def set_patient
    @patient = Patient.find(params[:patient_id])
  end

  before_filter :set_wallet_transaction, only: [:show, :edit, :update, :destroy]
  def set_wallet_transaction
    @patient = Patient.find(params[:patient_id])
    @wallet_transaction = @patient.wallet_transactions.find(params[:id])
  end

  # GET patient/:patient_id/wallet_transactions
  # GET patient/:patient_id/wallet_transactions.json
  def index
    @wallet_transactions = @patient.wallet_transactions.order('created_at DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @wallet_transactions }
    end
  end

  # GET patient/:patient_id/wallet_transactions/1
  # GET patient/:patient_id/wallet_transactions/1.json
  def show
    @wallet_transactions = @patient.wallet_transactions.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @wallet_transactions }
    end
  end

  # GET patient/:patient_id/wallet_transactions/new
  # GET patient/:patient_id/wallet_transactions/new.json
  def new
    @wallet_transaction = @patient.wallet_transactions.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @wallet_transaction }
    end
  end

  # GET patient/:patient_id/wallet_transactions/1/edit
  def edit
    #@wallet_transaction = WalletTransaction.find(params[:id])
  end

  # POST /wallet_transactions
  # POST /wallet_transactions.json
  def create
    @wallet_transaction = @patient.wallet_transactions.new(params[:wallet_transaction])

    respond_to do |format|
      if @wallet_transaction.save
        format.html { redirect_to [@patient, @wallet_transaction], notice: 'Transaction was successfully saved.' }
        format.json { render json: [@patient, @wallet_transaction], status: :created, location: @wallet_transaction }
      else
        format.html { render action: "new" }
        format.json { render json: @wallet_transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /wallet_transactions/1
  # PUT /wallet_transactions/1.json
  def update
    respond_to do |format|
      if @wallet_transaction.update_attributes(params[:wallet_transaction])
        format.html { redirect_to [@patient, @wallet_transaction], notice: 'Transaction was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @wallet_transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wallet_transactions/1
  # DELETE /wallet_transactions/1.json
  def destroy
    @wallet_transaction.destroy

    respond_to do |format|
      format.html { redirect_to patient_wallet_transactions_url(patient) }
      format.json { head :no_content }
    end
  end

end
