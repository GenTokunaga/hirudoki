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
end
