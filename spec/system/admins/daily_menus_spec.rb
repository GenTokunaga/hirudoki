describe '日別献立の管理', type: :system do
  before do
    sign_in create(:admin), scope: :admin
  end

  it '献立を登録すると、その月の一覧に残数とあわせて表示されること' do
    create(:bento, name: '鮭の塩焼き弁当', bento_type: :japanese)

    visit admins_daily_menus_path
    click_link '献立を登録'
    fill_in '提供日', with: '2026-12-01'
    select '鮭の塩焼き弁当（和食）', from: '弁当'
    fill_in '提供数上限', with: '20'
    click_button '登録する'

    expect(page).to have_content '2026/12/01 鮭の塩焼き弁当の献立を登録しました。'
    expect(page).to have_css 'h2', text: '2026年12月'
    daily_menu = DailyMenu.find_by!(served_on: Date.new(2026, 12, 1))
    within "[data-test-id='#{dom_id(daily_menu)}']" do
      expect(page).to have_content '12/1(火)'
      expect(page).to have_content '和食'
      expect(page).to have_content '鮭の塩焼き弁当'
      expect(page).to have_css "[data-test-id='stock-limit']", text: '20'
      expect(page).to have_css "[data-test-id='remaining-stock']", text: '20'
    end
  end

  it '同じ提供日に同じ弁当タイプの献立を 2 件目として登録できないこと' do
    create(:daily_menu, served_on: Date.new(2026, 12, 1), bento: create(:bento, bento_type: :japanese))
    create(:bento, name: '肉じゃが弁当', bento_type: :japanese)

    visit new_admins_daily_menu_path
    fill_in '提供日', with: '2026-12-01'
    select '肉じゃが弁当（和食）', from: '弁当'
    fill_in '提供数上限', with: '20'
    click_button '登録する'

    expect(page).to have_content '2026/12/01 の和食の献立はすでに登録されています。'
    expect(DailyMenu.count).to eq 1
  end

  it '表示する月の指定が不正なときは今月の献立を表示すること' do
    travel_to Time.zone.local(2026, 12, 15, 9, 0)

    visit admins_daily_menus_path(month: '2026-13')

    expect(page).to have_css 'h2', text: '2026年12月'
  end

  it '注文がある献立は削除できないこと' do
    daily_menu = create(:daily_menu, served_on: Date.new(2026, 12, 1))
    create(:order, daily_menu:)

    visit admins_daily_menus_path(month: '2026-12')
    within("[data-test-id='#{dom_id(daily_menu)}']") { click_button '削除' }

    expect(page).to have_content '注文が存在しているので削除できません'
    expect(page).to have_css "[data-test-id='#{dom_id(daily_menu)}']"
  end
end
