FactoryBot.define do
  factory :bento do
    sequence(:name) { |n| "日替わり弁当#{n}" }
    description { '季節の食材を使ったお弁当です。' }
    bento_type { :japanese }
    price { 600 }
    on_sale { true }
    sequence(:position) { |n| n }
  end
end
