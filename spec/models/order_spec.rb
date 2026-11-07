require "rails_helper"

RSpec.describe Order, type: :model do
  it "必要な項目がそろっていれば有効" do
    expect(build(:order)).to be_valid
  end

  it "ステータスの既定値は注文済" do
    expect(Order.new.status).to eq "ordered"
  end

  it "ステータスは注文済／受取済／キャンセル済の3種類" do
    expect(Order.statuses.keys).to eq %w[ordered received canceled]
    expect(build(:order, status: "shipped")).to be_invalid
  end

  describe "個数" do
    it "1〜3 は有効" do
      (1..3).each { |q| expect(build(:order, quantity: q)).to be_valid }
    end

    [ 0, 4 ].each do |quantity|
      it "#{quantity} は無効で、DB でも弾かれる" do
        order = build(:order, quantity: quantity)

        expect(order).to be_invalid
        expect_db_to_reject(order)
      end
    end
  end

  describe "金額" do
    %i[unit_price discount_per_unit total_price].each do |attribute|
      it "#{attribute} はマイナス不可（DB でも弾かれる）" do
        order = build(:order, attribute => -1)

        expect(order).to be_invalid
        expect_db_to_reject(order)
      end
    end
  end

  describe "生成元の定期注文設定" do
    it "手動注文は空でよい" do
      expect(build(:order, subscription: nil)).to be_valid
    end

    it "定期注文から生成した注文は設定を参照できる" do
      subscription = create(:subscription)

      expect(build(:order, subscription: subscription)).to be_valid
    end
  end

  it "配達先住所は必須" do
    expect(build(:order, delivery_address: "")).to be_invalid
  end
end
