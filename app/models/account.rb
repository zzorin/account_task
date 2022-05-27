class Account < ApplicationRecord
  belongs_to :admin_user
  has_many :financial_transactions, :dependent => :destroy
  validates :balance, numericality: { greater_than_or_equal_to: 0 }
end
