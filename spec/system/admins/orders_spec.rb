describe '注文の管理', type: :system do
  before do
    travel_to Time.zone.local(2026, 12, 1, 12, 0)
    sign_in create(:admin), scope: :admin
  end

  it '提供日ごとに注文が一覧に表示され、別の提供日に切り替えられること' do
    today_order = create(:order, user: create(:user, name: '山田 太郎'),
                                 daily_menu: create(:daily_menu, bento: create(:bento, name: '鮭の塩焼き弁当'), served_on: Date.new(2026, 12, 1)),
                                 quantity: 2, total_price: 1404)
    tomorrow_order = create(:order, user: create(:user, name: '佐藤 花子'),
                                    daily_menu: create(:daily_menu, bento: create(:bento, name: 'ハンバーグ弁当'), served_on: Date.new(2026, 12, 2)))

    visit admins_orders_path

    expect(page).to have_css 'h2', text: '12/1(火) 提供分'
    within("[data-test-id='#{dom_id(today_order)}']") do
      expect(page).to have_content '山田 太郎'
      expect(page).to have_content '鮭の塩焼き弁当'
      expect(page).to have_content '2 個'
      expect(page).to have_content '1,404円'
      expect(page).to have_content '注文済'
    end
    expect(page).to have_no_content '佐藤 花子'

    click_link '次の日 ›'

    expect(page).to have_css 'h2', text: '12/2(水) 提供分'
    expect(page).to have_css "[data-test-id='#{dom_id(tomorrow_order)}']", text: '佐藤 花子'
    expect(page).to have_no_content '山田 太郎'
  end

  it '注文のステータスを受取済・キャンセル済に変更できること' do
    order = create(:order, daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 1)))

    visit admins_order_path(order)
    select '受取済', from: 'ステータス'
    click_button 'ステータスを変更する'

    expect(page).to have_content 'ステータスを「受取済」に変更しました。'
    expect(page).to have_css "[data-test-id='order-status']", text: '受取済'

    select 'キャンセル済', from: 'ステータス'
    click_button 'ステータスを変更する'

    expect(page).to have_content 'ステータスを「キャンセル済」に変更しました。'
    expect(page).to have_css "[data-test-id='order-status']", text: 'キャンセル済'
  end

  it '締切を過ぎた注文でも、管理者はステータスを変更できること' do
    order = create(:order, daily_menu: create(:daily_menu, served_on: Date.new(2026, 11, 30)))

    visit admins_order_path(order)
    select '受取済', from: 'ステータス'
    click_button 'ステータスを変更する'

    expect(page).to have_content 'ステータスを「受取済」に変更しました。'
    expect(order.reload).to be_received
  end

  it 'キャンセル済から戻すと残数を超える注文は、戻せずに理由が表示されること' do
    daily_menu = create(:daily_menu, served_on: Date.new(2026, 12, 1), stock_limit: 3)
    create(:order, daily_menu:, quantity: 2)
    order = create(:order, :canceled, daily_menu:, quantity: 2)

    visit admins_order_path(order)
    select '注文済', from: 'ステータス'
    click_button 'ステータスを変更する'

    expect(page).to have_content 'キャンセル済から戻すと残数を超えるため変更できません（この注文 2 個、残り 1 個）'
    expect(page).to have_css "[data-test-id='order-status']", text: 'キャンセル済'
    expect(order.reload).to be_canceled
  end

  it '利用者としてログインしていても、注文の管理画面には入れないこと' do
    sign_out :admin
    sign_in create(:user)

    visit admins_orders_path

    expect(page).to have_current_path new_admin_session_path
  end
end
