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

  describe '#place' do
    def build_order(daily_menu:, user: create(:user), quantity: 1, delivery_area: create(:delivery_area))
      user.orders.build(daily_menu:, quantity:, delivery_area:, delivery_address: '東京都渋谷区神南1-1-1')
    end

    context '提供日当日の締切（10:00）' do
      it '9:59 なら注文できること' do
        order = build_order(daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 1)))

        expect(order.place(now: Time.zone.local(2026, 12, 1, 9, 59))).to be true
      end

      it '10:00 ちょうどなら注文できること' do
        order = build_order(daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 1)))

        expect(order.place(now: Time.zone.local(2026, 12, 1, 10, 0))).to be true
      end

      it '10:01 なら注文できないこと' do
        order = build_order(daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 1)))

        expect(order.place(now: Time.zone.local(2026, 12, 1, 10, 1))).to be false
        expect(order.errors[:base]).to include '注文の締切（提供日当日 10:00）を過ぎているため注文できません'
      end

      it '提供日が過ぎた献立は注文できないこと' do
        order = build_order(daily_menu: create(:daily_menu, served_on: Date.new(2026, 11, 30)))

        expect(order.place(now: Time.zone.local(2026, 12, 1, 8, 0))).to be false
        expect(order.errors[:base]).to include '注文の締切（提供日当日 10:00）を過ぎているため注文できません'
      end
    end

    context '注文できる提供日（14 日先まで）' do
      it '14 日先の提供日なら注文できること' do
        order = build_order(daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 15)))

        expect(order.place(now: Time.zone.local(2026, 12, 1, 12, 0))).to be true
      end

      it '15 日先の提供日は注文できないこと' do
        order = build_order(daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 16)))

        expect(order.place(now: Time.zone.local(2026, 12, 1, 12, 0))).to be false
        expect(order.errors[:base]).to include '注文できるのは 14 日先の提供日までです'
      end
    end

    context '残数' do
      it '残数ちょうどの個数なら注文できること' do
        daily_menu = create(:daily_menu, served_on: Date.new(2026, 12, 2), stock_limit: 5)
        create(:order, daily_menu:, quantity: 3)
        order = build_order(daily_menu:, quantity: 2)

        expect(order.place(now: Time.zone.local(2026, 12, 1, 12, 0))).to be true
      end

      it '残数より 1 個多いと注文できないこと' do
        daily_menu = create(:daily_menu, served_on: Date.new(2026, 12, 2), stock_limit: 5)
        create(:order, daily_menu:, quantity: 3)
        order = build_order(daily_menu:, quantity: 3)

        expect(order.place(now: Time.zone.local(2026, 12, 1, 12, 0))).to be false
        expect(order.errors[:quantity]).to include 'は残り 2 個以下にしてください'
      end

      it 'キャンセル済みの注文の個数は残数から引かないこと' do
        daily_menu = create(:daily_menu, served_on: Date.new(2026, 12, 2), stock_limit: 3)
        create(:order, :canceled, daily_menu:, quantity: 3)
        order = build_order(daily_menu:, quantity: 3)

        expect(order.place(now: Time.zone.local(2026, 12, 1, 12, 0))).to be true
      end
    end

    context '1 人 1 日の合計個数（3 個まで）' do
      it '同じ提供日の注文と合わせて 3 個なら注文できること' do
        user = create(:user)
        create(:order, user:, daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 2)), quantity: 2)
        order = build_order(user:, daily_menu: create(:daily_menu, bento: create(:bento, bento_type: :western), served_on: Date.new(2026, 12, 2)))

        expect(order.place(now: Time.zone.local(2026, 12, 1, 12, 0))).to be true
      end

      it '同じ提供日の注文と合わせて 4 個になると注文できないこと' do
        user = create(:user)
        create(:order, user:, daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 2)), quantity: 2)
        order = build_order(user:, daily_menu: create(:daily_menu, bento: create(:bento, bento_type: :western), served_on: Date.new(2026, 12, 2)),
                            quantity: 2)

        expect(order.place(now: Time.zone.local(2026, 12, 1, 12, 0))).to be false
        expect(order.errors[:quantity]).to include 'は、同じ提供日の注文と合わせて 3 個までです（注文済み 2 個）'
      end

      it 'キャンセル済みの注文と、別の提供日の注文は合計に含めないこと' do
        user = create(:user)
        create(:order, :canceled, user:, daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 2)), quantity: 3)
        create(:order, user:, daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 3)), quantity: 3)
        order = build_order(user:, daily_menu: create(:daily_menu, bento: create(:bento, bento_type: :western), served_on: Date.new(2026, 12, 2)),
                            quantity: 3)

        expect(order.place(now: Time.zone.local(2026, 12, 1, 12, 0))).to be true
      end
    end

    it '非販売の弁当の献立は注文できないこと' do
      order = build_order(daily_menu: create(:daily_menu, bento: create(:bento, :not_on_sale), served_on: Date.new(2026, 12, 2)))

      expect(order.place(now: Time.zone.local(2026, 12, 1, 12, 0))).to be false
      expect(order.errors[:base]).to include 'この弁当は現在販売していないため注文できません'
    end

    it '無効な配達エリアには注文できないこと' do
      order = build_order(daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 2)), delivery_area: create(:delivery_area, :inactive))

      expect(order.place(now: Time.zone.local(2026, 12, 1, 12, 0))).to be false
      expect(order.errors[:delivery_area]).to include 'は現在配達を受け付けていません'
    end

    it '注文時の弁当の価格を単価に、割引単価を 0 円にして、合計金額とあわせて保存すること' do
      allow(Rails.configuration.x.hirudoki).to receive(:tax_rate_percent).and_return(8)
      order = build_order(daily_menu: create(:daily_menu, bento: create(:bento, price: 650), served_on: Date.new(2026, 12, 2)), quantity: 2)

      order.place(now: Time.zone.local(2026, 12, 1, 12, 0))

      expect(order.reload).to have_attributes(unit_price: 650, discount_per_unit: 0, total_price: 1404)
    end
  end
end
