describe SubscriptionOrderGeneration do
  # NOTE: 2026-12-02 は水曜日（wday 3）
  let(:wednesday) { Date.new(2026, 12, 2) }

  def run_generation(served_on:, now: Time.zone.local(2026, 12, 1, 12, 0))
    generation = described_class.new(served_on:)
    generation.run(now:)
    generation
  end

  describe '対象日' do
    it '当日の 9:59 なら生成できること' do
      generation = described_class.new(served_on: wednesday)

      expect(generation.run(now: Time.zone.local(2026, 12, 2, 9, 59))).to be true
    end

    it '当日の 10:00 ちょうどには生成できないこと' do
      generation = described_class.new(served_on: wednesday)

      expect(generation.run(now: Time.zone.local(2026, 12, 2, 10, 0))).to be false
      expect(generation.errors[:served_on]).to include 'が当日の場合、生成できるのは 10:00 までです'
    end

    it '過去の日付には生成できないこと' do
      generation = described_class.new(served_on: wednesday)

      expect(generation.run(now: Time.zone.local(2026, 12, 3, 8, 0))).to be false
      expect(generation.errors[:served_on]).to include 'に過去の日付は指定できません'
    end

    it '14 日先なら生成でき、15 日先は生成できないこと' do
      now = Time.zone.local(2026, 12, 1, 12, 0)

      expect(described_class.new(served_on: Date.new(2026, 12, 15)).run(now:)).to be true
      generation = described_class.new(served_on: Date.new(2026, 12, 16))
      expect(generation.run(now:)).to be false
      expect(generation.errors[:served_on]).to include 'は 14 日先までにしてください'
    end

    it '土曜は献立があっても何も生成せず、土日として扱うこと' do
      saturday = Date.new(2026, 12, 5)
      create(:daily_menu, served_on: saturday, bento: create(:bento, bento_type: :healthy))
      create(:subscription, wday: 5, bento_type: :healthy)

      generation = run_generation(served_on: saturday)

      expect(generation).to be_weekend
      expect(generation.generated_orders).to be_empty
      expect(Order.count).to eq 0
    end
  end

  describe '注文の生成' do
    it '曜日が一致する有効な設定から、同じタイプの献立で 50 円引きの注文を作ること' do
      daily_menu = create(:daily_menu, served_on: wednesday, bento: create(:bento, bento_type: :healthy, price: 700))
      create(:daily_menu, served_on: wednesday, bento: create(:bento, bento_type: :japanese))
      subscription = create(:subscription, wday: 3, bento_type: :healthy, quantity: 2, delivery_address: '東京都渋谷区神南1-1-1')

      generation = run_generation(served_on: wednesday)

      order = generation.generated_orders.sole
      expect(order).to have_attributes(
        user: subscription.user, daily_menu:, subscription:, quantity: 2, delivery_area: subscription.delivery_area,
        delivery_address: '東京都渋谷区神南1-1-1', unit_price: 700, discount_per_unit: 50, total_price: 1404, status: 'ordered'
      )
    end

    it '曜日が違う設定と無効な設定からは作らないこと' do
      create(:daily_menu, served_on: wednesday, bento: create(:bento, bento_type: :healthy))
      create(:subscription, wday: 4, bento_type: :healthy)
      create(:subscription, wday: 3, bento_type: :healthy, active: false)

      generation = run_generation(served_on: wednesday)

      expect(generation.generated_orders).to be_empty
      expect(generation.skips).to be_empty
    end

    it '残数を超えていても作ること' do
      daily_menu = create(:daily_menu, served_on: wednesday, stock_limit: 2, bento: create(:bento, bento_type: :healthy))
      create(:order, daily_menu:, quantity: 2)
      create(:subscription, wday: 3, bento_type: :healthy, quantity: 3)

      generation = run_generation(served_on: wednesday)

      expect(generation.generated_orders.size).to eq 1
      expect(daily_menu.reload.remaining_stock).to eq 0
    end

    it '生成後に設定や弁当の価格を変えても、生成済みの注文は変わらないこと' do
      bento = create(:bento, bento_type: :healthy, price: 700)
      create(:daily_menu, served_on: wednesday, bento:)
      subscription = create(:subscription, wday: 3, bento_type: :healthy, quantity: 2, delivery_address: '東京都渋谷区神南1-1-1')
      order = run_generation(served_on: wednesday).generated_orders.sole

      subscription.update!(quantity: 1, delivery_address: '東京都渋谷区道玄坂2-2-2', bento_type: :japanese)
      bento.update!(price: 900)

      expect(order.reload).to have_attributes(quantity: 2, delivery_address: '東京都渋谷区神南1-1-1', unit_price: 700, total_price: 1404)
    end
  end

  describe 'スキップ' do
    def skip_reasons(generation)
      generation.skips.map { [it.subscription, it.reason] }
    end

    it '同じタイプの献立がなければ「献立がない」でスキップすること' do
      create(:daily_menu, served_on: wednesday, bento: create(:bento, bento_type: :japanese))
      subscription = create(:subscription, wday: 3, bento_type: :healthy)

      generation = run_generation(served_on: wednesday)

      expect(skip_reasons(generation)).to eq [[subscription, :no_daily_menu]]
    end

    it '同じタイプの献立が非販売の弁当なら「献立がない」でスキップすること' do
      create(:daily_menu, served_on: wednesday, bento: create(:bento, :not_on_sale, bento_type: :healthy))
      subscription = create(:subscription, wday: 3, bento_type: :healthy)

      generation = run_generation(served_on: wednesday)

      expect(skip_reasons(generation)).to eq [[subscription, :no_daily_menu]]
    end

    it '配達エリアが無効なら「エリアが無効」でスキップすること' do
      create(:daily_menu, served_on: wednesday, bento: create(:bento, bento_type: :healthy))
      delivery_area = create(:delivery_area)
      subscription = create(:subscription, wday: 3, bento_type: :healthy, delivery_area:)
      delivery_area.update!(active: false)

      generation = run_generation(served_on: wednesday)

      expect(skip_reasons(generation)).to eq [[subscription, :inactive_delivery_area]]
    end

    it '手動の注文と合わせて 1 日 3 個を超えるなら「1 日の上限を超える」でスキップすること' do
      create(:daily_menu, served_on: wednesday, bento: create(:bento, bento_type: :healthy))
      user = create(:user)
      create(:order, user:, daily_menu: create(:daily_menu, served_on: wednesday, bento: create(:bento, bento_type: :japanese)), quantity: 2)
      subscription = create(:subscription, user:, wday: 3, bento_type: :healthy, quantity: 2)

      generation = run_generation(served_on: wednesday)

      expect(skip_reasons(generation)).to eq [[subscription, :exceeds_daily_limit]]
    end

    it '手動の注文と合わせてちょうど 3 個なら生成すること' do
      create(:daily_menu, served_on: wednesday, bento: create(:bento, bento_type: :healthy))
      user = create(:user)
      create(:order, user:, daily_menu: create(:daily_menu, served_on: wednesday, bento: create(:bento, bento_type: :japanese)), quantity: 1)
      create(:subscription, user:, wday: 3, bento_type: :healthy, quantity: 2)

      generation = run_generation(served_on: wednesday)

      expect(generation.generated_orders.size).to eq 1
    end

    it 'キャンセル済みの手動の注文は 1 日の個数に数えないこと' do
      create(:daily_menu, served_on: wednesday, bento: create(:bento, bento_type: :healthy))
      user = create(:user)
      create(:order, :canceled, user:, daily_menu: create(:daily_menu, served_on: wednesday, bento: create(:bento, bento_type: :japanese)), quantity: 3)
      create(:subscription, user:, wday: 3, bento_type: :healthy, quantity: 3)

      generation = run_generation(served_on: wednesday)

      expect(generation.generated_orders.size).to eq 1
    end

    it '再実行しても二重に生成せず「すでに生成済み」でスキップすること' do
      create(:daily_menu, served_on: wednesday, bento: create(:bento, bento_type: :healthy))
      subscription = create(:subscription, wday: 3, bento_type: :healthy)
      run_generation(served_on: wednesday)

      generation = run_generation(served_on: wednesday)

      expect(skip_reasons(generation)).to eq [[subscription, :already_generated]]
      expect(Order.count).to eq 1
    end

    it '生成した注文がキャンセルされていても作り直さないこと' do
      create(:daily_menu, served_on: wednesday, bento: create(:bento, bento_type: :healthy))
      subscription = create(:subscription, wday: 3, bento_type: :healthy)
      run_generation(served_on: wednesday).generated_orders.sole.update!(status: :canceled)

      generation = run_generation(served_on: wednesday)

      expect(skip_reasons(generation)).to eq [[subscription, :already_generated]]
      expect(Order.count).to eq 1
    end
  end
end
