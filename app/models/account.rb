class Account < ApplicationRecord
  belongs_to :admin_user
  validates :balance, numericality: { greater_than_or_equal_to: 0 }
end
