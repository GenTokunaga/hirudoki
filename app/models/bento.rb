class Bento < ApplicationRecord
  # 弁当タイプ。定期注文設定（Subscription）でも同じ値を使う。
  # DB には英語のキーを保存し、画面では ja.yml の訳（和食／洋食／中華／ヘルシー）を表示する。
  BENTO_TYPES = {
    japanese: "japanese",
    western: "western",
    chinese: "chinese",
    healthy: "healthy"
  }.freeze

  enum :bento_type, BENTO_TYPES, validate: true

  has_one_attached :image
  # 献立から参照されている弁当は削除できない（仕様 3-7）。販売をやめるときは非販売にする。
  has_many :daily_menus, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 50 }
  validates :price, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :on_sale, inclusion: { in: [ true, false ] }
  validates :position, presence: true, numericality: { only_integer: true }
end
