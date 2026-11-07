class Order < ApplicationRecord
  enum :status, {
    ordered: 'ordered',   # 注文済
    received: 'received', # 受取済
    canceled: 'canceled', # キャンセル済
  }, default: :ordered, validate: true

  belongs_to :user
  belongs_to :daily_menu
  belongs_to :delivery_area
  # 値があれば定期注文から生成された注文。手動注文は nil。
  belongs_to :subscription, optional: true
  has_one :review, dependent: :restrict_with_error

  validates :quantity, numericality: { only_integer: true, in: 1..3 }
  validates :delivery_address, presence: true, length: { maximum: 255 }
  validates :unit_price, :discount_per_unit, :total_price,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
