require 'rails_helper'

RSpec.describe DailyMenu, type: :model do
  it '必要な項目がそろっていれば有効' do
    expect(build(:daily_menu)).to be_valid
  end

  it '提供日・弁当・提供数上限は必須' do
    menu = DailyMenu.new

    expect(menu).not_to be_valid
    expect(menu.errors.attribute_names).to include(:served_on, :bento, :stock_limit)
  end

  describe '提供数上限' do
    it '0 は有効' do
      expect(build(:daily_menu, stock_limit: 0)).to be_valid
    end

    it 'マイナスは無効で、DB でも弾かれる' do
      expect(build(:daily_menu, stock_limit: -1)).not_to be_valid
      expect_db_to_reject(build(:daily_menu, stock_limit: -1))
    end
  end

  describe '提供日 × 弁当の一意性' do
    let(:bento) { create(:bento) }
    let(:date) { Date.new(2026, 12, 1) }

    before { create(:daily_menu, bento: bento, served_on: date) }

    it '同じ日に同じ弁当は登録できず、DB でも弾かれる' do
      duplicate = build(:daily_menu, bento: bento, served_on: date)

      expect(duplicate).not_to be_valid
      expect_db_to_reject(duplicate, ActiveRecord::RecordNotUnique)
    end

    it '別の日なら同じ弁当を登録できる' do
      expect(build(:daily_menu, bento: bento, served_on: date + 1.day)).to be_valid
    end
  end

  it '注文がある献立は削除できない' do
    menu = create(:daily_menu)
    create(:order, daily_menu: menu)

    expect(menu.destroy).to be false
  end
end
