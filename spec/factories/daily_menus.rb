FactoryBot.define do
  factory :daily_menu do
    bento
    sequence(:served_on) { |n| Date.new(2026, 12, 1) + n.days }
    stock_limit { 20 }
  end
end
