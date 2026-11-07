require "rails_helper"

RSpec.describe DeliveryArea, type: :model do
  it "必要な項目がそろっていれば有効" do
    expect(build(:delivery_area)).to be_valid
  end

  it "有効フラグの既定値は true" do
    expect(DeliveryArea.new.active).to be true
  end

  describe "郵便番号" do
    it "ハイフンなし7桁は有効" do
      expect(build(:delivery_area, postal_code: "1500041")).to be_valid
    end

    %w[150-0041 150004 15000411 abcdefg].each do |code|
      it "#{code} は無効" do
        expect(build(:delivery_area, postal_code: code)).to be_invalid
      end
    end

    it "7桁以外は DB でも弾かれる" do
      expect_db_to_reject(build(:delivery_area, postal_code: "150-0041"))
    end

    it "一意" do
      create(:delivery_area, postal_code: "1500041")

      expect(build(:delivery_area, postal_code: "1500041")).to be_invalid
      expect_db_to_reject(build(:delivery_area, postal_code: "1500041"), ActiveRecord::RecordNotUnique)
    end
  end

  it "エリア名は必須" do
    expect(build(:delivery_area, name: "")).to be_invalid
  end

  describe "削除" do
    let(:area) { create(:delivery_area) }

    it "どこからも参照されていなければ削除できる" do
      expect(area.destroy).to be_truthy
    end

    it "注文から参照されていると削除できない" do
      create(:order, delivery_area: area)

      expect(area.destroy).to be false
    end

    it "定期注文設定から参照されていると削除できない" do
      create(:subscription, delivery_area: area)

      expect(area.destroy).to be false
    end
  end
end
