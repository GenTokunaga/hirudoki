FactoryBot.define do
  factory :review do
    order { association :order, status: :received }
    rating { 5 }
    comment { 'おいしかったです。' }
  end
end
