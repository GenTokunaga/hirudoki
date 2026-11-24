describe Order do
  describe '#assign_total_price' do
    it '弁当の価格を変えても、注文に控えた単価と割引単価で再計算すること' do
      allow(Rails.configuration.x.hirudoki).to receive(:tax_rate_percent).and_return(8)
      bento = create(:bento, price: 600)
      order = create(:order, daily_menu: create(:daily_menu, bento:), unit_price: 600, discount_per_unit: 50, quantity: 1)
      bento.update!(price: 800)

      order.quantity = 2
      order.assign_total_price

      expect(order.total_price).to eq 1188
    end

    it '税率を変えても、作成済みの注文の合計金額は変わらないこと' do
      allow(Rails.configuration.x.hirudoki).to receive(:tax_rate_percent).and_return(8)
      order = build(:order, unit_price: 1000, discount_per_unit: 0, quantity: 1)
      order.assign_total_price
      order.save!
      allow(Rails.configuration.x.hirudoki).to receive(:tax_rate_percent).and_return(10)

      expect(order.price.total).to eq 1100
      expect(order.reload.total_price).to eq 1080
    end
  end
end
