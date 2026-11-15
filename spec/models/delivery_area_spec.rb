describe DeliveryArea do
  describe '郵便番号' do
    it 'ハイフン付きで入力しても 7 桁の数字で保存されること' do
      delivery_area = create(:delivery_area, postal_code: '150-0041')

      expect(delivery_area.postal_code).to eq '1500041'
    end

    it '全角で入力しても半角の数字で保存されること' do
      delivery_area = create(:delivery_area, postal_code: '１５０－００４１')

      expect(delivery_area.postal_code).to eq '1500041'
    end

    it '7 桁でなければ登録できないこと' do
      delivery_area = build(:delivery_area, postal_code: '150004')

      expect(delivery_area).not_to be_valid
    end

    it 'ハイフンの有無が違うだけの同じ郵便番号は登録できないこと' do
      create(:delivery_area, postal_code: '1500041')
      delivery_area = build(:delivery_area, postal_code: '150-0041')

      expect(delivery_area).not_to be_valid
      expect(delivery_area.errors[:postal_code]).to include 'はすでに存在します'
    end
  end

  describe '削除' do
    it '注文からも定期注文設定からも参照されていなければ削除できること' do
      delivery_area = create(:delivery_area)

      expect(delivery_area.destroy).to be_truthy
      expect(DeliveryArea.exists?(delivery_area.id)).to be false
    end

    it '注文から参照されているエリアは削除できないこと' do
      delivery_area = create(:delivery_area)
      create(:order, delivery_area:, status: :canceled)

      expect(delivery_area.destroy).to be false
      expect(delivery_area.errors.full_messages).to include '注文が存在しているので削除できません'
      expect(DeliveryArea.exists?(delivery_area.id)).to be true
    end

    it '定期注文設定から参照されているエリアは削除できないこと' do
      delivery_area = create(:delivery_area)
      create(:subscription, delivery_area:, active: false)

      expect(delivery_area.destroy).to be false
      expect(delivery_area.errors.full_messages).to include '定期注文設定が存在しているので削除できません'
      expect(DeliveryArea.exists?(delivery_area.id)).to be true
    end
  end
end
