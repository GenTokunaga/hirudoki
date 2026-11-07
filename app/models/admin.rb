class Admin < ApplicationRecord
  # NOTE: 仕様で管理者は画面から作成しない（シードで作成する）ため、registerable を付けていない
  devise :database_authenticatable, :rememberable, :validatable

  validates :name, presence: true, length: { maximum: 50 }
end
