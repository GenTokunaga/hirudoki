class DailyMenu < ApplicationRecord
  belongs_to :bento
  # 注文がある献立は削除できない（仕様 3-7）。
  has_many :orders, dependent: :restrict_with_error

  validates :served_on, presence: true
  validates :stock_limit, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :bento_id, uniqueness: { scope: :served_on }
end
