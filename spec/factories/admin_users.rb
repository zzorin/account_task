FactoryBot.define do
  factory :admin_user do |admin_user|
    sequence(:email){|n| "user#{n}@factory.com" }
    admin_user.password{ "secret" }
  end
end
