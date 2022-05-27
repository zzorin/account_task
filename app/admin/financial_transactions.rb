ActiveAdmin.register FinancialTransaction do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  actions :all, except: [:edit, :update]
  permit_params :title, :kind, :amount, :account_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:title, :kind, :amount, :account_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  controller do
    def create
      ActiveRecord::Base.transaction do
        @financial_transaction = FinancialTransaction.new(transaction_params)
        if @financial_transaction.save
          set_account_balance
        else
          render :new
        end
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
        redirect_to admin_financial_transactions_path, notice: 'Transaction succeed!'
      else
        render :new
      end
    end

    private

    def transaction_params
      params.require(:financial_transaction).permit(:title, :kind, :amount, :account_id)
    end
  end

end
