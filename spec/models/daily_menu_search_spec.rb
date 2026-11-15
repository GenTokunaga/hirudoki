describe DailyMenuSearch do
  describe '#daily_menus' do
    context '提供日を指定しない場合' do
      it '今日から 14 日先までの献立を返すこと' do
        bento = create(:bento)
        create(:daily_menu, bento:, served_on: Date.new(2026, 11, 30))
        today_menu = create(:daily_menu, bento:, served_on: Date.new(2026, 12, 1))
        last_menu = create(:daily_menu, bento:, served_on: Date.new(2026, 12, 15))
        create(:daily_menu, bento:, served_on: Date.new(2026, 12, 16))

        daily_menus = DailyMenuSearch.new.daily_menus(today: Date.new(2026, 12, 1))

        expect(daily_menus).to eq [today_menu, last_menu]
      end
    end

    context '提供日を指定した場合' do
      it 'その日の献立だけを返すこと' do
        bento = create(:bento)
        create(:daily_menu, bento:, served_on: Date.new(2026, 12, 1))
        target_menu = create(:daily_menu, bento:, served_on: Date.new(2026, 12, 2))

        daily_menus = DailyMenuSearch.new(served_on: '2026-12-02').daily_menus(today: Date.new(2026, 12, 1))

        expect(daily_menus).to eq [target_menu]
      end

      it '存在しない日付なら、指定しない場合と同じく今日から 14 日先までの献立を返すこと' do
        today_menu = create(:daily_menu, served_on: Date.new(2026, 12, 1))

        daily_menus = DailyMenuSearch.new(served_on: '2026-02-30').daily_menus(today: Date.new(2026, 12, 1))

        expect(daily_menus).to eq [today_menu]
      end
    end

    context '弁当タイプを指定した場合' do
      it 'その弁当タイプの献立だけを返すこと' do
        create(:daily_menu, bento: create(:bento, bento_type: :japanese), served_on: Date.new(2026, 12, 1))
        western_menu = create(:daily_menu, bento: create(:bento, bento_type: :western), served_on: Date.new(2026, 12, 1))

        daily_menus = DailyMenuSearch.new(bento_type: 'western').daily_menus(today: Date.new(2026, 12, 1))

        expect(daily_menus).to eq [western_menu]
      end

      it '存在しない弁当タイプなら、すべての弁当タイプの献立を返すこと' do
        japanese_menu = create(:daily_menu, bento: create(:bento, bento_type: :japanese, position: 1), served_on: Date.new(2026, 12, 1))
        western_menu = create(:daily_menu, bento: create(:bento, bento_type: :western, position: 2), served_on: Date.new(2026, 12, 1))

        daily_menus = DailyMenuSearch.new(bento_type: 'french').daily_menus(today: Date.new(2026, 12, 1))

        expect(daily_menus).to eq [japanese_menu, western_menu]
      end
    end

    it '非販売の弁当の献立は返さないこと' do
      on_sale_menu = create(:daily_menu, bento: create(:bento, bento_type: :japanese, on_sale: true), served_on: Date.new(2026, 12, 1))
      create(:daily_menu, bento: create(:bento, bento_type: :western, on_sale: false), served_on: Date.new(2026, 12, 1))

      daily_menus = DailyMenuSearch.new.daily_menus(today: Date.new(2026, 12, 1))

      expect(daily_menus).to eq [on_sale_menu]
    end
  end
end
