class Order < ApplicationRecord
  enum :status, {
    ordered: 'ordered',
    received: 'received',
    canceled: 'canceled',
  }, default: :ordered, validate: true

  belongs_to :user
  belongs_to :daily_menu
  belongs_to :delivery_area
  belongs_to :subscription, optional: true
  has_one :review, dependent: :restrict_with_error

  validates :quantity, numericality: { only_integer: true, in: 1..3 }
  validates :delivery_address, presence: true, length: { maximum: 255 }
  validates :unit_price, :discount_per_unit, :total_price,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
