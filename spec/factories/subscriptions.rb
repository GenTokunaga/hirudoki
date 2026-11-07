FactoryBot.define do
  factory :subscription do
    user
    delivery_area
    wday { 1 }
    bento_type { :healthy }
    quantity { 2 }
    delivery_address { '東京都渋谷区神南1-1-1' }
    active { true }
  end
end
