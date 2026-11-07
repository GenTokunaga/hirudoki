# 定期注文設定。曜日ごとに「どの弁当タイプを何個、どこへ届けるか」を持つ。
class Subscription < ApplicationRecord
  # 曜日は Date#wday と同じ番号で持つ（1=月 〜 5=金）。土日は選べない。
  WDAYS = (1..5)

  enum :bento_type, Bento::BENTO_TYPES, validate: true

  belongs_to :user
  belongs_to :delivery_area
  # 生成した注文は設定を変更・無効化しても残す。設定の削除機能は作らない。
  has_many :orders, dependent: :restrict_with_error

  validates :wday, inclusion: { in: WDAYS }, uniqueness: { scope: :user_id }
  validates :quantity, numericality: { only_integer: true, in: 1..3 }
  validates :delivery_address, presence: true, length: { maximum: 255 }
  validates :active, inclusion: { in: [ true, false ] }
end
