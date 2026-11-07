class Bento < ApplicationRecord
  BENTO_TYPES = %w[japanese western chinese healthy].index_with(&:itself).freeze

  enum :bento_type, BENTO_TYPES, validate: true

  has_one_attached :image
  # NOTE: 仕様 3-7。販売をやめるときは削除ではなく非販売にする運用のため、献立から参照されていれば削除できなくしている
  has_many :daily_menus, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 50 }
  validates :price, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :on_sale, inclusion: { in: [true, false] }
  validates :position, presence: true, numericality: { only_integer: true }
end
