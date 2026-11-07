class User < ApplicationRecord
  # 利用者は画面から登録できる（registerable）。
  # パスワード再設定（recoverable）はメール送信が必要なため使わない。
  devise :database_authenticatable, :registerable, :rememberable, :validatable

  # 配達時の連絡先。ハイフンの有無は問わず、数字 10〜11 桁を受け付ける。
  PHONE_NUMBER_FORMAT = /\A(?:\d{10,11}|\d{2,4}-\d{2,4}-\d{3,4})\z/

  validates :name, presence: true, length: { maximum: 50 }
  validates :phone_number, presence: true, format: { with: PHONE_NUMBER_FORMAT, allow_blank: true }
end
