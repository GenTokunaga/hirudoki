class Admin < ApplicationRecord
  # 管理者は画面から作成しないため registerable を付けない（シードで作成する）。
  devise :database_authenticatable, :rememberable, :validatable

  validates :name, presence: true, length: { maximum: 50 }
end
