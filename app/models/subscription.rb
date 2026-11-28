class Subscription < ApplicationRecord
  # NOTE: 曜日は Date#wday と同じ番号で持つ（1=月 〜 5=金）。生成時に対象日の wday とそのまま比較できるため
  WDAYS = (1..5)

  enum :bento_type, Bento::BENTO_TYPES, validate: true

  belongs_to :user
  belongs_to :delivery_area
  # NOTE: 仕様で設定の削除機能は作らない（無効化で代替）。生成済みの注文から参照されるため削除できなくしている
  has_many :orders, dependent: :restrict_with_error

  validates :wday, inclusion: { in: WDAYS }, uniqueness: { scope: :user_id }
  validates :quantity, numericality: { only_integer: true, in: 1..3 }
  validates :delivery_address, presence: true, length: { maximum: 255 }
  validates :active, inclusion: { in: [true, false] }

  # NOTE: 生成した注文は設定から独立させる（設定をあとで変えても生成済みの注文は変わらない）ため、参照ではなく値を写している
  def build_order(daily_menu:)
    order = user.orders.build(daily_menu:, subscription: self, quantity:, delivery_area:, delivery_address:,
                              unit_price: daily_menu.bento.price,
                              discount_per_unit: Rails.configuration.x.hirudoki.subscription_discount_per_unit)
    order.assign_total_price
    order
  end
end
