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

  describe '#submit' do
    def build_order(daily_menu:, user: create(:user), quantity: 1, delivery_area: create(:delivery_area))
      user.orders.build(daily_menu:, quantity:, delivery_area:, delivery_address: '東京都渋谷区神南1-1-1')
    end

    context '提供日当日の締切（10:00）' do
      it '9:59 なら注文できること' do
        order = build_order(daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 1)))

        expect(order.submit(now: Time.zone.local(2026, 12, 1, 9, 59))).to be true
      end

      it '10:00 ちょうどには注文できないこと' do
        order = build_order(daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 1)))

        expect(order.submit(now: Time.zone.local(2026, 12, 1, 10, 0))).to be false
        expect(order.errors[:base]).to include '注文の締切（提供日当日 10:00）を過ぎているため注文できません'
      end

      it '10:01 なら注文できないこと' do
        order = build_order(daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 1)))

        expect(order.submit(now: Time.zone.local(2026, 12, 1, 10, 1))).to be false
        expect(order.errors[:base]).to include '注文の締切（提供日当日 10:00）を過ぎているため注文できません'
      end

      it '提供日が過ぎた献立は注文できないこと' do
        order = build_order(daily_menu: create(:daily_menu, served_on: Date.new(2026, 11, 30)))

        expect(order.submit(now: Time.zone.local(2026, 12, 1, 8, 0))).to be false
        expect(order.errors[:base]).to include '注文の締切（提供日当日 10:00）を過ぎているため注文できません'
      end
    end

    context '注文できる提供日（14 日先まで）' do
      it '14 日先の提供日なら注文できること' do
        order = build_order(daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 15)))

        expect(order.submit(now: Time.zone.local(2026, 12, 1, 12, 0))).to be true
      end

      it '15 日先の提供日は注文できないこと' do
        order = build_order(daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 16)))

        expect(order.submit(now: Time.zone.local(2026, 12, 1, 12, 0))).to be false
        expect(order.errors[:base]).to include '注文できるのは 14 日先の提供日までです'
      end
    end

    context '残数' do
      it '残数ちょうどの個数なら注文できること' do
        daily_menu = create(:daily_menu, served_on: Date.new(2026, 12, 2), stock_limit: 5)
        create(:order, daily_menu:, quantity: 3)
        order = build_order(daily_menu:, quantity: 2)

        expect(order.submit(now: Time.zone.local(2026, 12, 1, 12, 0))).to be true
      end

      it '残数より 1 個多いと注文できないこと' do
        daily_menu = create(:daily_menu, served_on: Date.new(2026, 12, 2), stock_limit: 5)
        create(:order, daily_menu:, quantity: 3)
        order = build_order(daily_menu:, quantity: 3)

        expect(order.submit(now: Time.zone.local(2026, 12, 1, 12, 0))).to be false
        expect(order.errors[:quantity]).to include 'は残り 2 個以下にしてください'
      end

      it 'キャンセル済みの注文の個数は残数から引かないこと' do
        daily_menu = create(:daily_menu, served_on: Date.new(2026, 12, 2), stock_limit: 3)
        create(:order, :canceled, daily_menu:, quantity: 3)
        order = build_order(daily_menu:, quantity: 3)

        expect(order.submit(now: Time.zone.local(2026, 12, 1, 12, 0))).to be true
      end
    end

    context '1 人 1 日の合計個数（3 個まで）' do
      it '同じ提供日の注文と合わせて 3 個なら注文できること' do
        user = create(:user)
        create(:order, user:, daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 2)), quantity: 2)
        order = build_order(user:, daily_menu: create(:daily_menu, bento: create(:bento, bento_type: :western), served_on: Date.new(2026, 12, 2)))

        expect(order.submit(now: Time.zone.local(2026, 12, 1, 12, 0))).to be true
      end

      it '同じ提供日の注文と合わせて 4 個になると注文できないこと' do
        user = create(:user)
        create(:order, user:, daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 2)), quantity: 2)
        order = build_order(user:, daily_menu: create(:daily_menu, bento: create(:bento, bento_type: :western), served_on: Date.new(2026, 12, 2)),
                            quantity: 2)

        expect(order.submit(now: Time.zone.local(2026, 12, 1, 12, 0))).to be false
        expect(order.errors[:quantity]).to include 'は、同じ提供日の注文と合わせて 3 個までです（注文済み 2 個）'
      end

      it 'キャンセル済みの注文と、別の提供日の注文は合計に含めないこと' do
        user = create(:user)
        create(:order, :canceled, user:, daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 2)), quantity: 3)
        create(:order, user:, daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 3)), quantity: 3)
        order = build_order(user:, daily_menu: create(:daily_menu, bento: create(:bento, bento_type: :western), served_on: Date.new(2026, 12, 2)),
                            quantity: 3)

        expect(order.submit(now: Time.zone.local(2026, 12, 1, 12, 0))).to be true
      end
    end

    it '非販売の弁当の献立は注文できないこと' do
      order = build_order(daily_menu: create(:daily_menu, bento: create(:bento, :not_on_sale), served_on: Date.new(2026, 12, 2)))

      expect(order.submit(now: Time.zone.local(2026, 12, 1, 12, 0))).to be false
      expect(order.errors[:base]).to include 'この弁当は現在販売していないため注文できません'
    end

    it '無効な配達エリアには注文できないこと' do
      order = build_order(daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 2)), delivery_area: create(:delivery_area, :inactive))

      expect(order.submit(now: Time.zone.local(2026, 12, 1, 12, 0))).to be false
      expect(order.errors[:delivery_area]).to include 'は現在配達を受け付けていません'
    end

    it '注文時の弁当の価格を単価に、割引単価を 0 円にして、合計金額とあわせて保存すること' do
      allow(Rails.configuration.x.hirudoki).to receive(:tax_rate_percent).and_return(8)
      order = build_order(daily_menu: create(:daily_menu, bento: create(:bento, price: 650), served_on: Date.new(2026, 12, 2)), quantity: 2)

      order.submit(now: Time.zone.local(2026, 12, 1, 12, 0))

      expect(order.reload).to have_attributes(unit_price: 650, discount_per_unit: 0, total_price: 1404)
    end
  end

  describe '#change_quantity' do
    it '残数は変更前の自分の個数を戻してから判定し、戻した残数ちょうどまでは変更できること' do
      daily_menu = create(:daily_menu, served_on: Date.new(2026, 12, 2), stock_limit: 5)
      create(:order, daily_menu:, quantity: 2)
      order = create(:order, daily_menu:, quantity: 1)

      expect(order.change_quantity(3, now: Time.zone.local(2026, 12, 1, 12, 0))).to be true
    end

    it '自分の個数を戻した残数を超える個数には変更できないこと' do
      daily_menu = create(:daily_menu, served_on: Date.new(2026, 12, 2), stock_limit: 4)
      create(:order, daily_menu:, quantity: 2)
      order = create(:order, daily_menu:, quantity: 1)

      expect(order.change_quantity(3, now: Time.zone.local(2026, 12, 1, 12, 0))).to be false
      expect(order.errors[:quantity]).to include 'は残り 2 個以下にしてください'
    end

    it '同じ提供日の他の注文と合わせて 4 個になる個数には変更できないこと' do
      user = create(:user)
      create(:order, user:, daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 2)), quantity: 2)
      order = create(:order, user:, daily_menu: create(:daily_menu, bento: create(:bento, bento_type: :western), served_on: Date.new(2026, 12, 2)))

      expect(order.change_quantity(2, now: Time.zone.local(2026, 12, 1, 12, 0))).to be false
      expect(order.errors[:quantity]).to include 'は、同じ提供日の注文と合わせて 3 個までです（注文済み 2 個）'
    end

    it '弁当の価格を変えた後でも、注文時の単価と割引単価で合計金額を計算し直すこと' do
      allow(Rails.configuration.x.hirudoki).to receive(:tax_rate_percent).and_return(8)
      bento = create(:bento, price: 600)
      order = create(:order, daily_menu: create(:daily_menu, bento:, served_on: Date.new(2026, 12, 2)),
                             unit_price: 600, discount_per_unit: 50, quantity: 1, total_price: 594)
      bento.update!(price: 800)

      order.change_quantity(3, now: Time.zone.local(2026, 12, 1, 12, 0))

      expect(order.reload).to have_attributes(quantity: 3, total_price: 1782)
    end

    it '提供日当日の 9:59 なら変更できること' do
      order = create(:order, daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 1)))

      expect(order.change_quantity(2, now: Time.zone.local(2026, 12, 1, 9, 59))).to be true
    end

    it '提供日当日の 10:00 ちょうどには変更できないこと' do
      order = create(:order, daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 1)))

      expect(order.change_quantity(2, now: Time.zone.local(2026, 12, 1, 10, 0))).to be false
      expect(order.errors[:base]).to include '締切（提供日当日 10:00）を過ぎたため、個数の変更やキャンセルができません'
    end

    it '受取済みの注文は変更できないこと' do
      order = create(:order, :received, daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 2)))

      expect(order.change_quantity(2, now: Time.zone.local(2026, 12, 1, 12, 0))).to be false
      expect(order.errors[:base]).to include '受取済の注文は、個数の変更やキャンセルができません'
    end
  end

  describe '#cancel' do
    it '提供日当日の 9:59 ならキャンセル済みになること' do
      order = create(:order, daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 1)))

      expect(order.cancel(now: Time.zone.local(2026, 12, 1, 9, 59))).to be true
      expect(order.reload).to be_canceled
    end

    it '提供日当日の 10:00 ちょうどにはキャンセルできず、ステータスが変わらないこと' do
      order = create(:order, daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 1)))

      expect(order.cancel(now: Time.zone.local(2026, 12, 1, 10, 0))).to be false
      expect(order.reload).to be_ordered
    end

    it 'キャンセル済みの注文は、もう一度キャンセルできないこと' do
      order = create(:order, :canceled, daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 2)))

      expect(order.cancel(now: Time.zone.local(2026, 12, 1, 12, 0))).to be false
      expect(order.errors[:base]).to include 'キャンセル済の注文は、個数の変更やキャンセルができません'
    end
  end

  describe '#change_status' do
    it 'キャンセル済から戻すとき、残数ちょうどなら戻せること' do
      daily_menu = create(:daily_menu, stock_limit: 5)
      create(:order, daily_menu:, quantity: 3)
      order = create(:order, :canceled, daily_menu:, quantity: 2)

      expect(order.change_status(:ordered)).to be true
      expect(order.reload).to be_ordered
    end

    it 'キャンセル済から戻すと残数を超えるときは、戻せないこと' do
      daily_menu = create(:daily_menu, stock_limit: 5)
      create(:order, daily_menu:, quantity: 3)
      order = create(:order, :canceled, daily_menu:, quantity: 3)

      expect(order.change_status(:ordered)).to be false
      expect(order.errors[:base]).to include 'キャンセル済から戻すと残数を超えるため変更できません（この注文 3 個、残り 2 個）'
      expect(order.reload).to be_canceled
    end

    it 'キャンセル済から戻すと、利用者の同じ提供日の注文が 4 個になるときは、戻せないこと' do
      user = create(:user)
      create(:order, user:, daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 2)), quantity: 2)
      order = create(:order, :canceled, user:, daily_menu: create(:daily_menu, bento: create(:bento, bento_type: :western), served_on: Date.new(2026, 12, 2)),
                                        quantity: 2)

      expect(order.change_status(:received)).to be false
      expect(order.errors[:base]).to include 'キャンセル済から戻すと、この利用者の同じ提供日の注文が 3 個を超えるため変更できません（この注文 2 個、注文済み 2 個）'
    end

    it 'キャンセル済から戻すのでなければ、残数を超えていても変更できること' do
      # NOTE: 管理者が提供数上限を下げた後でも、既存の注文の受取済への変更は止めないことを確かめるため、上限を注文より少なくしている
      daily_menu = create(:daily_menu, stock_limit: 1)
      order = create(:order, daily_menu:, quantity: 3)

      expect(order.change_status(:received)).to be true
    end
  end
end
