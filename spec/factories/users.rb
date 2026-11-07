FactoryBot.define do
  factory :user do
    name { 'ひるどき 太郎' }
    sequence(:email) { |n| "user#{n}@example.com" }
    phone_number { '090-1234-5678' }
    password { 'password123' }
  end
end
