require "rails_helper"

RSpec.describe Bento, type: :model do
  it "必要な項目がそろっていれば有効" do
    expect(build(:bento)).to be_valid
  end

  it "販売フラグの既定値は true" do
    expect(Bento.new.on_sale).to be true
  end

  it "弁当名・価格・表示順は必須" do
    bento = build(:bento, name: "", price: nil, position: nil)

    expect(bento).to be_invalid
    expect(bento.errors.attribute_names).to include(:name, :price, :position)
  end

  describe "弁当タイプ" do
    it "和食／洋食／中華／ヘルシーの4種類" do
      expect(Bento.bento_types.keys).to eq %w[japanese western chinese healthy]
    end

    it "それ以外の値は無効" do
      bento = build(:bento, bento_type: "french")

      expect(bento).to be_invalid
      expect(bento.errors[:bento_type]).to be_present
    end

    it "それ以外の値は DB でも弾かれる" do
      bento = build(:bento)
      bento.bento_type = "japanese"
      bento.save!
      expect { bento.update_column(:bento_type, "french") }.to raise_error(ActiveRecord::StatementInvalid)
    end

    it "画面表示用の日本語名がある" do
      expect(Bento.bento_types.keys.map { |type| Bento.human_enum_name(:bento_type, type) })
        .to eq %w[和食 洋食 中華 ヘルシー]
      expect(Subscription.human_enum_name(:bento_type, :healthy)).to eq "ヘルシー"
      expect(Order.human_enum_name(:status, :canceled)).to eq "キャンセル済"
    end
  end

  describe "価格" do
    it "0 円は有効" do
      expect(build(:bento, price: 0)).to be_valid
    end

    it "マイナスは無効" do
      expect(build(:bento, price: -1)).to be_invalid
    end

    it "マイナスは DB でも弾かれる" do
      expect_db_to_reject(build(:bento, price: -1))
    end

    it "小数は無効" do
      expect(build(:bento, price: 100.5)).to be_invalid
    end
  end

  it "献立に使われている弁当は削除できない" do
    bento = create(:bento)
    create(:daily_menu, bento: bento)

    expect(bento.destroy).to be false
    expect(bento.errors[:base]).to be_present
  end
end
