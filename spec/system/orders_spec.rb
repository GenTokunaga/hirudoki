describe '手動注文', type: :system do
  before do
    travel_to Time.zone.local(2026, 12, 1, 9, 0)
  end

  it '献立から注文すると、注文内容と合計金額が表示されること' do
    allow(Rails.configuration.x.hirudoki).to receive(:tax_rate_percent).and_return(8)
    daily_menu = create(:daily_menu, bento: create(:bento, name: '鮭の塩焼き弁当', price: 650), served_on: Date.new(2026, 12, 2))
    create(:delivery_area, name: '渋谷区神南', postal_code: '1500041')
    sign_in create(:user)

    visit root_path
    within("[data-test-id='#{dom_id(daily_menu)}']") { click_link '注文する' }
    select '2 個', from: '個数'
    select '渋谷区神南（〒150-0041）', from: '配達エリア'
    fill_in '配達先住所', with: '東京都渋谷区神南1-1-1'
    click_button '注文する'

    expect(page).to have_content '注文しました。'
    expect(page).to have_css "[data-test-id='order-status']", text: '注文済'
    expect(page).to have_content '12/2(水)'
    expect(page).to have_content '鮭の塩焼き弁当'
    expect(page).to have_content '2 個'
    expect(page).to have_content '渋谷区神南'
    expect(page).to have_content '東京都渋谷区神南1-1-1'
    expect(page).to have_content '1,404円'
  end

  it '個数・配達エリア・配達先住所に必須の表示が付くこと' do
    sign_in create(:user)

    visit new_daily_menu_order_path(create(:daily_menu, served_on: Date.new(2026, 12, 2)))

    # NOTE: 「必須」のバッジは label.required の CSS（::after）で出しているため、クラスで確かめている
    expect(page).to have_css 'label.required', text: '個数'
    expect(page).to have_css 'label.required', text: '配達エリア'
    expect(page).to have_css 'label.required', text: '配達先住所'
  end

  it '配達エリアと住所の初期値が、直近の注文の内容になること' do
    user = create(:user)
    create(:order, user:, delivery_area: create(:delivery_area, name: '渋谷区宇田川町', postal_code: '1500042'),
                   delivery_address: '東京都渋谷区宇田川町2-2-2')
    daily_menu = create(:daily_menu, served_on: Date.new(2026, 12, 3))
    sign_in user

    visit new_daily_menu_order_path(daily_menu)

    expect(page).to have_select '配達エリア', selected: '渋谷区宇田川町（〒150-0042）'
    expect(page).to have_field '配達先住所', with: '東京都渋谷区宇田川町2-2-2'
  end

  it '締切前の献立は注文でき、締切を過ぎた献立は注文ボタンが押せず理由が表示されること' do
    open_menu = create(:daily_menu, served_on: Date.new(2026, 12, 2))
    closed_menu = create(:daily_menu, served_on: Date.new(2026, 12, 1))
    sign_in create(:user)
    travel_to Time.zone.local(2026, 12, 1, 10, 1)

    visit root_path

    expect(page).to have_css "[data-test-id='#{dom_id(open_menu)}']", text: '注文する'
    within("[data-test-id='#{dom_id(closed_menu)}']") do
      expect(page).to have_button '受付終了', disabled: true
    end
  end

  it '画面を開いた後に締切を過ぎると、注文できずに理由が表示されること' do
    daily_menu = create(:daily_menu, served_on: Date.new(2026, 12, 1))
    create(:delivery_area, name: '渋谷区神南', postal_code: '1500041')
    sign_in create(:user)

    visit new_daily_menu_order_path(daily_menu)
    select '渋谷区神南（〒150-0041）', from: '配達エリア'
    fill_in '配達先住所', with: '東京都渋谷区神南1-1-1'
    travel_to Time.zone.local(2026, 12, 1, 10, 1)
    click_button '注文する'

    expect(page).to have_content '注文の締切（提供日当日 10:00）を過ぎているため注文できません'
    expect(Order.count).to eq 0
  end

  it '残数より多い個数は注文できず、理由が表示されること' do
    daily_menu = create(:daily_menu, served_on: Date.new(2026, 12, 2), stock_limit: 1)
    create(:delivery_area, name: '渋谷区神南', postal_code: '1500041')
    sign_in create(:user)

    visit new_daily_menu_order_path(daily_menu)
    select '2 個', from: '個数'
    select '渋谷区神南（〒150-0041）', from: '配達エリア'
    fill_in '配達先住所', with: '東京都渋谷区神南1-1-1'
    click_button '注文する'

    expect(page).to have_content '個数は残り 1 個以下にしてください'
    expect(Order.count).to eq 0
  end
end
