FactoryBot.define do
  factory :account do
    balance { 0.0 }

    association :admin_user
  end
end
