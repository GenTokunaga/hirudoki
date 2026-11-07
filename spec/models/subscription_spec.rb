require 'rails_helper'

RSpec.describe Subscription, type: :model do
  it '必要な項目がそろっていれば有効' do
    expect(build(:subscription)).to be_valid
  end

  it '有効フラグの既定値は true' do
    expect(Subscription.new.active).to be true
  end

  describe '曜日' do
    (1..5).each do |wday|
      it "#{wday}（月〜金）は有効" do
        expect(build(:subscription, wday: wday)).to be_valid
      end
    end

    [0, 6].each do |wday|
      it "#{wday}（土日）は無効で、DB でも弾かれる" do
        subscription = build(:subscription, wday: wday)

        expect(subscription).not_to be_valid
        expect_db_to_reject(subscription)
      end
    end

    it '1人につき同じ曜日は1件まで（DB でも弾かれる）' do
      user = create(:user)
      create(:subscription, user: user, wday: 1)
      duplicate = build(:subscription, user: user, wday: 1)

      expect(duplicate).not_to be_valid
      expect_db_to_reject(duplicate, ActiveRecord::RecordNotUnique)
    end

    it '別の利用者なら同じ曜日を設定できる' do
      create(:subscription, wday: 1)

      expect(build(:subscription, wday: 1)).to be_valid
    end
  end

  describe '個数' do
    it '1〜3 は有効' do
      (1..3).each { |q| expect(build(:subscription, quantity: q)).to be_valid }
    end

    [0, 4].each do |quantity|
      it "#{quantity} は無効で、DB でも弾かれる" do
        subscription = build(:subscription, quantity: quantity)

        expect(subscription).not_to be_valid
        expect_db_to_reject(subscription)
      end
    end
  end

  it '弁当タイプは弁当と同じ4種類' do
    expect(Subscription.bento_types).to eq Bento.bento_types
    expect(build(:subscription, bento_type: 'french')).not_to be_valid
  end

  it '配達先住所は必須' do
    expect(build(:subscription, delivery_address: '')).not_to be_valid
  end
end
