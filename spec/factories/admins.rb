FactoryBot.define do
  factory :admin do
    name { "管理者" }
    sequence(:email) { |n| "admin#{n}@example.com" }
    password { "password123" }
  end
end
