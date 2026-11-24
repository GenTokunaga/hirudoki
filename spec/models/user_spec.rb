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
end
