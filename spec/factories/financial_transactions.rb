FactoryBot.define do
  factory :financial_transaction do
    sequence(:title){|n| "title_#{n}" }
    starting_balance { 0.0 }
    amount { 1.0 }

    association :account
  end
end
