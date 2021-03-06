require 'rails_helper'

RSpec.describe Admin::FinancialTransactionsController, type: :controller do
  let!(:admin_user) { create :admin_user }

  before(:each) do
    sign_in admin_user
  end
  describe 'GET index' do
    let!(:account) { create(:account, admin_user: admin_user) }
    it 'returns correct balance' do
      post :create, params: { financial_transaction: {"account_id"=>account.id, "amount"=>"10.5"} }
      FinancialTransaction.first.update(created_at: DateTime.now - 2.days)
      post :create, params: { financial_transaction: {"account_id"=>account.id, "amount"=>"0.5"} }
      get :index, params: {
        "q"=>{
          "account_id_eq"=>account.id, "created_at_gteq_datetime"=>FinancialTransaction.last.created_at.strftime("%Y-%m-%d")
          },
        "commit"=>"Filter",
        "order"=>"created_at_asc"
      }
      collection = controller.view_assigns['financial_transactions']
      expect(collection.count).to eq(1)
      expect(collection.first.starting_balance).to eq(10.5)
      expect(collection.last.starting_balance + collection.last.amount).to eq(11)
    end
  end
  describe 'POST create' do
    let!(:account)  { create :account, admin_user: admin_user }
    context 'when valid params passed' do
      it 'creates transaction, changes acccount balance' do
        expect do
          post :create, params: { financial_transaction: {"account_id"=>account.id, "amount"=>"10.0"} }
        end.to change(FinancialTransaction, :count).by(1)
        expect(account.reload.balance).to eq(10.0)
      end
    end
    context 'final balance less than zero' do
      it 'returns validation error' do
        expect do
          post :create, params: { financial_transaction: {"account_id"=>account.id, "amount"=>"-1.0"} }
        end.not_to change(FinancialTransaction, :count)
        expect(account.reload.balance).to eq(0.0)
      end
    end
    context 'when account locked' do
      it 'does not create transaction' do
        threads = []

        threads << Thread.new do
          ActiveRecord::Base.transaction do
            Account.lock('FOR UPDATE NOWAIT').find_by(id: account.id)
            sleep(2)
          end
        end
        threads << Thread.new do
          expect do
            post :create, params: { financial_transaction: {"account_id"=>account.id, "amount"=>"10.0"} }
          end.not_to change(FinancialTransaction, :count)
        end

        threads.each { |thr| thr.join }
        expect(account.reload.balance).to eq(0.0)
      end
    end
  end
end
