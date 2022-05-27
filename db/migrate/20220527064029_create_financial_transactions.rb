class CreateFinancialTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :financial_transactions do |t|
      t.string :title
      t.string :kind
      t.float :amount, default: 0, null: false
      t.references :account, foreign_key: true, index: true
      t.timestamps
    end
  end
end
