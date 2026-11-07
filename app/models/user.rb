class User < ApplicationRecord
  # NOTE: パスワード再設定（recoverable）はメール送信が必要で、通知全般が課題の対象外のため付けていない
  devise :database_authenticatable, :registerable, :rememberable, :validatable

  # NOTE: 退会は課題の対象外。誤って削除して注文履歴や請求が失われないよう、関連があれば削除できなくしている
  has_many :orders, dependent: :restrict_with_error
  has_many :subscriptions, dependent: :restrict_with_error

  PHONE_NUMBER_FORMAT = /\A(?:\d{10,11}|\d{2,4}-\d{2,4}-\d{3,4})\z/

  validates :name, presence: true, length: { maximum: 50 }
  validates :phone_number, presence: true, format: { with: PHONE_NUMBER_FORMAT, allow_blank: true }
end
