class Subscription < ApplicationRecord
  # NOTE: 曜日は Date#wday と同じ番号で持つ（1=月 〜 5=金）。生成時に対象日の wday とそのまま比較できるため
  WDAYS = (1..5)

  enum :bento_type, Bento::BENTO_TYPES, validate: true

  belongs_to :user
  belongs_to :delivery_area
  # NOTE: 仕様で設定の削除機能は作らない（無効化で代替）。生成済みの注文から参照されるため削除できなくしている
  has_many :orders, dependent: :restrict_with_error

  validates :wday, inclusion: { in: WDAYS }, uniqueness: { scope: :user_id }
  validates :quantity, numericality: { only_integer: true, in: Order::QUANTITY_RANGE }
  validates :delivery_address, presence: true, length: { maximum: 255 }
  validates :active, inclusion: { in: [true, false] }
  # NOTE: 管理者があとからエリアを無効にしても、利用者が他の項目を編集できるよう、エリアを選び直すときだけ確認している。
  #       無効なエリアの設定は、定期注文の生成でスキップする
  validate :delivery_area_must_be_active, if: :will_save_change_to_delivery_area_id?

  scope :ordered, -> { order(:wday) }

  private

  def delivery_area_must_be_active
    return if delivery_area.nil? || delivery_area.active?

    errors.add(:delivery_area, :inactive)
  end
end
