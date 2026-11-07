FactoryBot.define do
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
end
