FactoryBot.define do
  factory :delivery_area do
    sequence(:name) { |n| "渋谷区神南#{n}丁目" }
    sequence(:postal_code) { |n| format('150%04d', n) }
    active { true }
  end
end
