FactoryBot.define do
  factory :bento do
    sequence(:name) { |n| "日替わり弁当#{n}" }
    bento_type { :japanese }
    price { 600 }
    sequence(:position) { |n| n }

    trait :not_on_sale do
      on_sale { false }
    end
  end
end
