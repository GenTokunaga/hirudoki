describe DailyMenu do
  describe '同じ提供日の弁当タイプ' do
    it '同じ提供日に同じ弁当タイプの献立は 2 件目を登録できないこと' do
      create(:daily_menu, served_on: Date.new(2026, 12, 1), bento: create(:bento, bento_type: :japanese))
      daily_menu = build(:daily_menu, served_on: Date.new(2026, 12, 1), bento: create(:bento, bento_type: :japanese))

      expect(daily_menu).not_to be_valid
      expect(daily_menu.errors.full_messages).to include '2026/12/01 の和食の献立はすでに登録されています。1日に登録できるのは弁当タイプごとに1件です'
    end

    it '同じ提供日でも弁当タイプが違えば登録できること' do
      create(:daily_menu, served_on: Date.new(2026, 12, 1), bento: create(:bento, bento_type: :japanese))
      daily_menu = build(:daily_menu, served_on: Date.new(2026, 12, 1), bento: create(:bento, bento_type: :western))

      expect(daily_menu).to be_valid
    end

    it '提供日が違えば同じ弁当タイプでも登録できること' do
      bento = create(:bento, bento_type: :japanese)
      create(:daily_menu, served_on: Date.new(2026, 12, 1), bento:)
      daily_menu = build(:daily_menu, served_on: Date.new(2026, 12, 2), bento:)

      expect(daily_menu).to be_valid
    end

    it '登録済みの献立を編集するときは自分自身と重複扱いにならないこと' do
      daily_menu = create(:daily_menu, stock_limit: 20)

      expect(daily_menu.update(stock_limit: 30)).to be true
    end
  end

  describe '提供数上限' do
    it '0 なら登録できること' do
      daily_menu = build(:daily_menu, stock_limit: 0)

      expect(daily_menu).to be_valid
    end

    it '-1 なら登録できないこと' do
      daily_menu = build(:daily_menu, stock_limit: -1)

      expect(daily_menu).not_to be_valid
      expect(daily_menu.errors[:stock_limit]).to include 'は0以上の値にしてください'
    end

    it '1,000 なら登録できること' do
      daily_menu = build(:daily_menu, stock_limit: 1_000)

      expect(daily_menu).to be_valid
    end

    it '1,001 なら登録できないこと' do
      daily_menu = build(:daily_menu, stock_limit: 1_001)

      expect(daily_menu).not_to be_valid
      expect(daily_menu.errors[:stock_limit]).to include 'は1000以下の値にしてください'
    end
  end

  describe '.parse_month' do
    it '「年-月」の形式なら、その月の 1 日を返すこと' do
      expect(DailyMenu.parse_month('2026-12', fallback: Date.new(2026, 11, 15))).to eq Date.new(2026, 12, 1)
    end

    it '存在しない月なら、fallback の月の 1 日を返すこと' do
      expect(DailyMenu.parse_month('2026-13', fallback: Date.new(2026, 11, 15))).to eq Date.new(2026, 11, 1)
    end

    it '形式が違えば、fallback の月の 1 日を返すこと' do
      expect(DailyMenu.parse_month('2026/12', fallback: Date.new(2026, 11, 15))).to eq Date.new(2026, 11, 1)
    end

    it '指定がなければ、fallback の月の 1 日を返すこと' do
      expect(DailyMenu.parse_month(nil, fallback: Date.new(2026, 11, 15))).to eq Date.new(2026, 11, 1)
    end
  end

  describe '#remaining_stock' do
    it '提供数上限からキャンセル済みを除く注文の個数を引いた値になること' do
      daily_menu = create(:daily_menu, stock_limit: 10)
      create(:order, daily_menu:, quantity: 3, status: :ordered)
      create(:order, daily_menu:, quantity: 2, status: :received)
      create(:order, daily_menu:, quantity: 3, status: :canceled)

      expect(daily_menu.remaining_stock).to eq 5
    end

    it '注文がなければ提供数上限と同じになること' do
      daily_menu = create(:daily_menu, stock_limit: 10)

      expect(daily_menu.remaining_stock).to eq 10
    end

    it '注文の個数が提供数上限を超えていても 0 になること' do
      daily_menu = create(:daily_menu, stock_limit: 2)
      create(:order, daily_menu:, quantity: 3)

      expect(daily_menu.remaining_stock).to eq 0
    end
  end

  describe '削除' do
    it '注文がなければ削除できること' do
      daily_menu = create(:daily_menu)

      expect(daily_menu.destroy).to be_truthy
      expect(DailyMenu.exists?(daily_menu.id)).to be false
    end

    it 'キャンセル済みの注文しかなくても削除できないこと' do
      daily_menu = create(:daily_menu)
      create(:order, daily_menu:, status: :canceled)

      expect(daily_menu.destroy).to be false
      expect(daily_menu.errors.full_messages).to include '注文が存在しているので削除できません'
      expect(DailyMenu.exists?(daily_menu.id)).to be true
    end
  end

  describe '注文がある献立の変更' do
    it '提供数上限は変更できること' do
      daily_menu = create(:daily_menu, stock_limit: 10)
      create(:order, daily_menu:)

      expect(daily_menu.update(stock_limit: 20)).to be true
    end

    it '弁当は変更できないこと' do
      daily_menu = create(:daily_menu)
      create(:order, daily_menu:)

      expect(daily_menu.update(bento: create(:bento))).to be false
      expect(daily_menu.errors.full_messages).to include '注文がある献立は、提供日と弁当を変更できません'
    end

    it '提供日は変更できないこと' do
      daily_menu = create(:daily_menu, served_on: Date.new(2026, 12, 1))
      create(:order, daily_menu:)

      expect(daily_menu.update(served_on: Date.new(2026, 12, 2))).to be false
    end
  end
end
