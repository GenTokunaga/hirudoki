class DailyMenu < ApplicationRecord
  belongs_to :bento
  has_many :orders, dependent: :restrict_with_error

  validates :served_on, presence: true
  validates :stock_limit, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :bento_id, uniqueness: { scope: :served_on }
end
