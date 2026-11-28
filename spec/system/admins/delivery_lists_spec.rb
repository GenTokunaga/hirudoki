describe '製造・配達リスト', type: :system do
  before do
    travel_to Time.zone.local(2026, 12, 1, 12, 0)
    sign_in create(:admin), scope: :admin
  end

  it '指定した提供日の弁当ごとの合計個数と配達先が、キャンセル済みを除いて表示されること' do
    salmon = create(:bento, name: '鮭の塩焼き弁当', bento_type: :japanese)
    hamburg = create(:bento, name: 'ハンバーグ弁当', bento_type: :western)
    salmon_menu = create(:daily_menu, bento: salmon, served_on: Date.new(2026, 12, 2))
    hamburg_menu = create(:daily_menu, bento: hamburg, served_on: Date.new(2026, 12, 2))
    delivery_area = create(:delivery_area, name: '渋谷区神南')
    yamada_order = create(:order, daily_menu: salmon_menu, quantity: 3, delivery_area:, delivery_address: '東京都渋谷区神南1-1-1',
                                  user: create(:user, name: '山田 太郎', phone_number: '090-1111-2222'))
    create(:order, daily_menu: salmon_menu, quantity: 2)
    create(:order, :canceled, daily_menu: salmon_menu, quantity: 1, user: create(:user, name: 'キャンセル 次郎'))
    create(:order, :canceled, daily_menu: hamburg_menu, quantity: 3)
    create(:order, daily_menu: create(:daily_menu, bento: hamburg, served_on: Date.new(2026, 12, 3)), quantity: 1)

    visit admins_bentos_path
    click_link '製造・配達'
    fill_in '提供日', with: '2026-12-02'
    click_button '表示'

    expect(page).to have_css 'h2', text: '12/2(水) 提供分'
    within "[data-test-id='production-list']" do
      expect(page).to have_css "[data-test-id='#{dom_id(salmon)}'] [data-test-id='total-quantity']", text: '5 個'
      expect(page).to have_no_content 'ハンバーグ弁当'
    end
    within "[data-test-id='delivery-list']" do
      within "[data-test-id='#{dom_id(yamada_order)}']" do
        expect(page).to have_content '渋谷区神南'
        expect(page).to have_content '東京都渋谷区神南1-1-1'
        expect(page).to have_content '山田 太郎'
        expect(page).to have_content '090-1111-2222'
        expect(page).to have_content '鮭の塩焼き弁当'
        expect(page).to have_content '3 個'
      end
      expect(page).to have_no_content 'キャンセル 次郎'
    end
  end

  it '注文がない提供日は、その旨が表示されること' do
    visit admins_delivery_list_path(served_on: '2026-12-02')

    expect(page).to have_content '製造する弁当はありません。'
    expect(page).to have_content '配達する注文はありません。'
  end
end
