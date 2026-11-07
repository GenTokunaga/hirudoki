class DeliveryArea < ApplicationRecord
  # NOTE: 仕様 3-7。配達をやめるときは削除ではなく無効にする運用のため、参照されていれば削除できなくしている
  has_many :orders, dependent: :restrict_with_error
  has_many :subscriptions, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 50 }
  validates :postal_code, presence: true,
                          format: { with: /\A\d{7}\z/, allow_blank: true },
                          uniqueness: true
  validates :active, inclusion: { in: [true, false] }
end
