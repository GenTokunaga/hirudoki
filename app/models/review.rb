class Review < ApplicationRecord
  belongs_to :order

  validates :rating, presence: true, numericality: { only_integer: true, in: 1..5, allow_nil: true }
  validates :order_id, uniqueness: true
  validates :comment, length: { maximum: 1000 }
  validate :order_must_be_received, on: :create

  private

  def order_must_be_received
    return if order.nil? || order.received?

    errors.add(:base, :order_not_received)
  end
end
