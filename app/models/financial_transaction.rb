class FinancialTransaction < ApplicationRecord
  extend Enumerize

  enumerize :kind, in: [:deposit, :withdrawal]
  belongs_to :account
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
end
