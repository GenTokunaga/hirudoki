describe User do
  describe '#build_order' do
    it '配達エリアと住所の初期値を、ステータスを問わず作成日時が最も新しい注文から取ること' do
      user = create(:user)
      latest_area = create(:delivery_area)
      create(:order, user:, delivery_address: '東京都渋谷区神南1-1-1', created_at: Time.zone.local(2026, 11, 20, 12, 0))
      create(:order, :canceled, user:, delivery_area: latest_area, delivery_address: '東京都渋谷区宇田川町2-2-2',
                                created_at: Time.zone.local(2026, 11, 25, 12, 0))

      order = user.build_order(daily_menu: create(:daily_menu))

      expect(order).to have_attributes(delivery_area_id: latest_area.id, delivery_address: '東京都渋谷区宇田川町2-2-2')
    end

    it '注文がなければ配達エリアと住所を空にすること' do
      user = create(:user)

      order = user.build_order(daily_menu: create(:daily_menu))

      expect(order).to have_attributes(delivery_area_id: nil, delivery_address: nil)
    end
  end

  describe '#billing_amount_for' do
    it '提供日がその月の 1 日〜末日の注文を合計し、前後の月の注文は含めないこと' do
      user = create(:user)
      create(:order, user:, daily_menu: create(:daily_menu, served_on: Date.new(2026, 11, 30)), total_price: 5000)
      create(:order, user:, daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 1)), total_price: 702)
      create(:order, user:, daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 31)), total_price: 1404)
      create(:order, user:, daily_menu: create(:daily_menu, served_on: Date.new(2027, 1, 1)), total_price: 7000)

      expect(user.billing_amount_for(Date.new(2026, 12, 1))).to eq 2106
    end

    it 'キャンセル済みの注文と、他の利用者の注文は含めないこと' do
      user = create(:user)
      create(:order, user:, daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 10)), total_price: 702)
      create(:order, :received, user:, daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 11)), total_price: 1404)
      create(:order, :canceled, user:, daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 12)), total_price: 3000)
      create(:order, daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 13)), total_price: 9000)

      expect(user.billing_amount_for(Date.new(2026, 12, 1))).to eq 2106
    end

    it '注文がない月は 0 円になること' do
      user = create(:user)

      expect(user.billing_amount_for(Date.new(2026, 12, 1))).to eq 0
    end
  end
end
