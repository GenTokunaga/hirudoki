describe OrderPrice do
  describe '#subtotal' do
    it '割引後の単価に個数を掛けた金額になること' do
      price = OrderPrice.new(unit_price: 600, discount_per_unit: 50, quantity: 3)

      expect(price.subtotal).to eq 1650
    end

    it '割引額が単価と同じときは 0 円になること' do
      price = OrderPrice.new(unit_price: 50, discount_per_unit: 50, quantity: 2)

      expect(price.subtotal).to eq 0
    end

    it '割引額が単価を超えても 0 円未満にならないこと' do
      price = OrderPrice.new(unit_price: 30, discount_per_unit: 50, quantity: 2)

      expect(price.subtotal).to eq 0
    end
  end

  describe '#tax・#total' do
    it '消費税の 1 円未満は切り捨て、合計は小計に消費税を足した金額になること' do
      # NOTE: 655 円 × 8% = 52.4 円。四捨五入でも切り上げでもなく切り捨てになることを確かめるため、端数の出る単価にしている
      price = OrderPrice.new(unit_price: 655, discount_per_unit: 0, quantity: 1, tax_rate_percent: 8)

      expect(price.tax).to eq 52
      expect(price.total).to eq 707
    end

    it '端数が 0.5 円以上でも切り捨てること' do
      # NOTE: 657 円 × 8% = 52.56 円。四捨五入なら 53 円になる値
      price = OrderPrice.new(unit_price: 657, discount_per_unit: 0, quantity: 1, tax_rate_percent: 8)

      expect(price.tax).to eq 52
      expect(price.total).to eq 709
    end

    it '小計が 0 円なら消費税も合計も 0 円になること' do
      price = OrderPrice.new(unit_price: 30, discount_per_unit: 50, quantity: 3, tax_rate_percent: 8)

      expect(price.tax).to eq 0
      expect(price.total).to eq 0
    end

    it '税率を指定しなければ config/hirudoki.yml の税率（8%）で計算すること' do
      price = OrderPrice.new(unit_price: 1000, discount_per_unit: 0, quantity: 1)

      expect(price.tax).to eq 80
    end
  end
end
