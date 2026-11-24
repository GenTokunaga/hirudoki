describe '利用者の管理と請求', type: :system do
  before do
    travel_to Time.zone.local(2026, 12, 15, 12, 0)
    sign_in create(:admin), scope: :admin
  end

  it '利用者の一覧から詳細を開くと、今月の請求額と注文が表示され、月を切り替えられること' do
    user = create(:user, name: '山田 太郎', email: 'yamada@example.com', phone_number: '090-1111-2222')
    december_order = create(:order, user:, daily_menu: create(:daily_menu, bento: create(:bento, name: '鮭の塩焼き弁当'), served_on: Date.new(2026, 12, 1)),
                                    total_price: 702)
    canceled_order = create(:order, :canceled, user:, daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 2)), total_price: 3000)
    create(:order, user:, daily_menu: create(:daily_menu, bento: create(:bento, name: 'ハンバーグ弁当'), served_on: Date.new(2027, 1, 4)),
                   total_price: 1404)

    visit admins_users_path
    within("[data-test-id='#{dom_id(user)}']") do
      expect(page).to have_content 'yamada@example.com'
      expect(page).to have_content '090-1111-2222'
      click_link '山田 太郎'
    end

    expect(page).to have_css 'h3', text: '2026年12月'
    expect(page).to have_css "[data-test-id='billing-amount']", text: '702円'
    expect(page).to have_css "[data-test-id='#{dom_id(december_order)}']", text: '鮭の塩焼き弁当'
    expect(page).to have_css "[data-test-id='#{dom_id(canceled_order)}']", text: 'キャンセル済'
    expect(page).to have_no_content 'ハンバーグ弁当'

    click_link '次の月 ›'

    expect(page).to have_css 'h3', text: '2027年1月'
    expect(page).to have_css "[data-test-id='billing-amount']", text: '1,404円'
    expect(page).to have_content 'ハンバーグ弁当'
    expect(page).to have_no_content '鮭の塩焼き弁当'
  end

  it '注文がない月は、請求額が 0 円でその旨が表示されること' do
    user = create(:user)

    visit admins_user_path(user, month: '2026-10')

    expect(page).to have_css "[data-test-id='billing-amount']", text: '0円'
    expect(page).to have_content 'この月の注文はありません。'
  end
end
