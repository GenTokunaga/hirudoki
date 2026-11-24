describe '注文の個数変更とキャンセル', type: :system do
  before do
    travel_to Time.zone.local(2026, 12, 1, 9, 0)
  end

  it '締切前の注文は、個数を変更してからキャンセルできること' do
    allow(Rails.configuration.x.hirudoki).to receive(:tax_rate_percent).and_return(8)
    user = create(:user)
    order = create(:order, user:, daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 2)),
                           unit_price: 650, discount_per_unit: 0, quantity: 1, total_price: 702)
    sign_in user

    visit order_path(order)
    click_link '個数を変更する'
    select '3 個', from: '個数'
    click_button '変更する'

    expect(page).to have_content '個数を変更しました。'
    expect(page).to have_content '3 個'
    expect(page).to have_content '2,106円'

    click_button 'キャンセルする'

    expect(page).to have_content '注文をキャンセルしました。'
    expect(page).to have_css "[data-test-id='order-status']", text: 'キャンセル済'
    within("[data-test-id='order-change-actions']") do
      expect(page).to have_button 'キャンセルする', disabled: true
      expect(page).to have_content 'キャンセル済の注文は、個数の変更やキャンセルができません'
    end
  end

  it '締切後の注文は、変更・キャンセルのボタンが押せず、理由が表示されること' do
    user = create(:user)
    order = create(:order, user:, daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 1)))
    sign_in user
    travel_to Time.zone.local(2026, 12, 1, 10, 1)

    visit order_path(order)

    within("[data-test-id='order-change-actions']") do
      expect(page).to have_button '個数を変更する', disabled: true
      expect(page).to have_button 'キャンセルする', disabled: true
      expect(page).to have_content '締切（提供日当日 10:00）を過ぎたため、個数の変更やキャンセルができません'
    end
  end

  it '締切後に個数の変更画面を直接開くと、注文の詳細に戻され理由が表示されること' do
    user = create(:user)
    order = create(:order, user:, daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 1)))
    sign_in user
    travel_to Time.zone.local(2026, 12, 1, 10, 1)

    visit edit_order_path(order)

    expect(page).to have_current_path order_path(order)
    expect(page).to have_content '締切（提供日当日 10:00）を過ぎたため、個数の変更やキャンセルができません'
  end

  it '残数を超える個数に変更しようとすると、理由が表示されて個数が変わらないこと' do
    user = create(:user)
    daily_menu = create(:daily_menu, served_on: Date.new(2026, 12, 2), stock_limit: 3)
    create(:order, daily_menu:, quantity: 2)
    order = create(:order, user:, daily_menu:, quantity: 1)
    sign_in user

    visit edit_order_path(order)
    select '2 個', from: '個数'
    click_button '変更する'

    expect(page).to have_content '個数は残り 1 個以下にしてください'
    expect(order.reload.quantity).to eq 1
  end
end
