describe '献立一覧', type: :system do
  before do
    travel_to Time.zone.local(2026, 12, 1, 9, 0)
  end

  it '提供日ごとに献立が表示され、提供日と弁当タイプで絞り込めること' do
    japanese_bento = create(:bento, name: '鮭の塩焼き弁当', bento_type: :japanese, price: 650, position: 1)
    western_bento = create(:bento, name: 'ハンバーグ弁当', bento_type: :western, price: 700, position: 2)
    create(:daily_menu, bento: japanese_bento, served_on: Date.new(2026, 12, 1))
    create(:daily_menu, bento: western_bento, served_on: Date.new(2026, 12, 1))
    target_menu = create(:daily_menu, bento: western_bento, served_on: Date.new(2026, 12, 2))

    visit root_path

    expect(page).to have_content '12/1(火) 〜 12/15(火) の献立'
    expect(page).to have_css 'h2', text: '12/1(火)'
    expect(page).to have_css 'h2', text: '12/2(水)'

    within("[data-test-id='daily-menu-search']") do
      fill_in '提供日', with: '2026-12-02'
      select '洋食', from: '弁当タイプ'
      click_button '絞り込む'
    end

    expect(page).to have_content '12/2(水) の献立'
    within("[data-test-id='#{dom_id(target_menu)}']") do
      expect(page).to have_content '洋食'
      expect(page).to have_content 'ハンバーグ弁当'
      expect(page).to have_content '700円'
    end
    expect(page).to have_no_content '鮭の塩焼き弁当'
  end

  it '残数と、残数がない献立は売り切れと表示されること' do
    daily_menu = create(:daily_menu, served_on: Date.new(2026, 12, 1), stock_limit: 5)
    create(:order, daily_menu:, quantity: 3)
    sold_out_menu = create(:daily_menu, bento: create(:bento, bento_type: :western), served_on: Date.new(2026, 12, 1), stock_limit: 0)

    visit root_path

    expect(page).to have_css "[data-test-id='#{dom_id(daily_menu)}']", text: '残り 2 個'
    expect(page).to have_css "[data-test-id='#{dom_id(sold_out_menu)}']", text: '売り切れ'
  end

  it '販売中の弁当の献立は表示され、非販売の弁当の献立は表示されないこと' do
    create(:daily_menu, bento: create(:bento, name: '鮭の塩焼き弁当', bento_type: :japanese), served_on: Date.new(2026, 12, 1))
    create(:daily_menu, bento: create(:bento, name: '麻婆豆腐弁当', bento_type: :chinese, on_sale: false), served_on: Date.new(2026, 12, 1))

    visit root_path

    expect(page).to have_content '鮭の塩焼き弁当'
    expect(page).to have_no_content '麻婆豆腐弁当'
  end

  it '条件に合う献立がないときは、その旨が表示されること' do
    visit root_path(served_on: '2026-12-03')

    expect(page).to have_content '条件に合う献立はありません。'
  end
end
