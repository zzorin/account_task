require 'rails_helper'

RSpec.describe Admin::FinancialTransactionsController, type: :controller do
  describe 'POST create' do
    it '' do
      expect do
        post :create, params: { financial_transaction: {"account_id"=>"1", "title"=>"title", "kind"=>"deposit", "amount"=>"10.0"} }
      end.to change(FinancialTransaction, :count).by(1)
    end
  end
end
