ActiveAdmin.register FinancialTransaction do
  actions :all, except: [:edit, :update]
  permit_params :title, :kind, :amount, :account_id

  controller do
    def create
      result = nil
      ActiveRecord::Base.transaction do
        %w(create_transaction set_account_balance).each do |method|
          result = send method
          raise ActiveRecord::Rollback if result.failure?
        end
      end

      if result.success?
        redirect_to admin_financial_transactions_path, notice: 'Transaction succeed!'
      else
        render :new, notice: result.message
      end
    end

    def create_transaction
      @financial_transaction = FinancialTransaction.new(transaction_params)
      if @financial_transaction.save
        success_result
      else
        invalid_params_result(@financial_transaction)
      end
    end

    def set_account_balance
      @account = Account.find_by(id: transaction_params[:account_id])
      amount = transaction_params[:amount].to_f
      if transaction_params[:kind] == 'deposit'
        @account.balance += amount
      else
        @account.balance -= amount
      end

      if @account.save
        success_result
      else
        invalid_params_result(@account)
      end
    end

    private

    def success_result(status: :success, message: nil, data: {})
      build_result success: true, status: status, message: message, data: data
    end

    def invalid_params_result(object)
      message = object.is_a?(ActiveRecord::Base) ? "#{object.model_name.human}: #{object.errors.full_messages.join('. ')}" : object
      build_result success: false, status: :invalid_params, message: message
    end

    def build_result(success:, status:, message: nil, data: {})
      Hashie::Mash.new(
        success?: success,
        failure?: !success,
        status: status,
        message: message,
        data: data
      )
    end

    def transaction_params
      params.require(:financial_transaction).permit(:title, :kind, :amount, :account_id)
    end
  end

end
