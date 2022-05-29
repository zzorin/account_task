ActiveAdmin.register FinancialTransaction do
  actions :all, except: [:edit, :update]
  permit_params :title, :amount, :account_id

  index do
    panel 'Balance' do
      render partial: 'balance'
    end
    table_for financial_transactions do
      column :id
      column :title
      column :starting_balance
      column :amount
      column :created_at
    end
  end

  filter :account, member_label: :id, include_blank: false
  filter :title
  filter :created_at

  form do |f|
    f.inputs do
      f.input :account, member_label: :id
      f.input :title
      f.input :amount
    end
    f.actions
  end

  controller do
    before_action :set_default_params, only: [:index]

    def set_default_params
      params[:order] = 'created_at_asc'
      params[:q] = {account_id_eq: Account.first&.id} if params[:commit].blank?
    end

    def create
      result = nil
      ActiveRecord::Base.transaction do
        %w(create_transaction set_account_balance).each do |method|
          result = send method
          raise ActiveRecord::Rollback unless result.success?
        end
      end

      if result.success?
        redirect_to admin_financial_transactions_path, notice: 'Transaction succeed!'
      else
        flash[:error] = result.message
        render :new
      end
    rescue => e
      flash[:error] = e.message
      redirect_to admin_financial_transactions_path
    end

    def create_transaction
      @account = Account.lock('FOR UPDATE NOWAIT').find_by(id: transaction_params[:account_id])
      @financial_transaction = FinancialTransaction.new(transaction_params)
      @financial_transaction.update(starting_balance: @account.balance)
      if @financial_transaction.save
        success_result
      else
        invalid_params_result(@financial_transaction)
      end
    end

    def set_account_balance
      amount = transaction_params[:amount].to_f
      @account.balance += amount
      if @account.save
        success_result
      else
        invalid_params_result(@account)
      end
    end

    private

    def success_result
      build_result success: true
    end

    def invalid_params_result(object)
      message = "#{object.model_name.human}: #{object.errors.full_messages.join('. ')}"
      build_result success: false, message: message
    end

    def build_result(success:, message: nil)
      Hashie::Mash.new(
        success?: success,
        message: message
      )
    end

    def transaction_params
      params.require(:financial_transaction).permit(:title, :amount, :account_id)
    end
  end

end
