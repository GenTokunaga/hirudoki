class Review < ApplicationRecord
  belongs_to :order

  validates :rating, numericality: { only_integer: true, in: 1..5 }
  validates :order_id, uniqueness: true
  validates :comment, length: { maximum: 1000 }
end
