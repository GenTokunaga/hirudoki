FactoryBot.define do
  factory :bento do
    sequence(:name) { |n| "日替わり弁当#{n}" }
    description { '季節の食材を使ったお弁当です。' }
    bento_type { :japanese }
    price { 600 }
    on_sale { true }
    sequence(:position) { |n| n }
  end

  factory :delivery_area do
    sequence(:name) { |n| "渋谷区神南#{n}丁目" }
    sequence(:postal_code) { |n| format('150%04d', n) }
    active { true }
  end

  factory :daily_menu do
    bento
    sequence(:served_on) { |n| Date.new(2026, 12, 1) + n.days }
    stock_limit { 20 }
  end

  factory :subscription do
    user
    delivery_area
    wday { 1 }
    bento_type { :healthy }
    quantity { 2 }
    delivery_address { '東京都渋谷区神南1-1-1' }
    active { true }
  end

  factory :order do
    user
    daily_menu
    delivery_area
    quantity { 1 }
    delivery_address { '東京都渋谷区神南1-1-1' }
    unit_price { 600 }
    discount_per_unit { 0 }
    total_price { 648 }
  end

  factory :review do
    order { association :order, status: :received }
    rating { 5 }
    comment { 'おいしかったです。' }
  end
end
