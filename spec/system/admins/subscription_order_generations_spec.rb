describe '定期注文の生成', type: :system do
  before do
    travel_to Time.zone.local(2026, 12, 1, 12, 0)
  end

  it '対象日を指定して生成すると、件数とスキップが表示され、利用者のマイページに注文が出ること' do
    create(:daily_menu, served_on: Date.new(2026, 12, 2), bento: create(:bento, name: '彩り野菜弁当', bento_type: :healthy))
    user = create(:user, name: '定期 花子')
    create(:subscription, user:, wday: 3, bento_type: :healthy, quantity: 2)
    create(:subscription, user: create(:user, name: '献立なし 次郎'), wday: 3, bento_type: :chinese)
    sign_in create(:admin), scope: :admin

    visit admins_bentos_path
    click_link '定期注文'
    fill_in '対象日', with: '2026-12-02'
    click_button '定期注文を生成する'

    expect(page).to have_css "a[aria-current='page']", text: '定期注文'
    expect(page).to have_css "[data-test-id='generation-summary']", text: '生成 1 件 / スキップ 1 件'
    within "[data-test-id='generated-orders']" do
      expect(page).to have_content '定期 花子'
      expect(page).to have_content '彩り野菜弁当'
      expect(page).to have_content '2 個'
    end
    within "[data-test-id='generation-skips']" do
      expect(page).to have_content '献立なし 次郎'
      expect(page).to have_content '同じ弁当タイプの販売中の献立がない'
    end

    sign_in user
    visit mypage_path
    expect(page).to have_content '12/2(水)'
    expect(page).to have_content '彩り野菜弁当'
  end

  it '過去の日付は指定できないこと' do
    sign_in create(:admin), scope: :admin

    visit new_admins_subscription_order_generation_path
    fill_in '対象日', with: '2026-11-30'
    click_button '定期注文を生成する'

    expect(page).to have_content '対象日に過去の日付は指定できません'
    expect(page).to have_no_css "[data-test-id='generation-summary']"
  end

  it '利用者は生成の画面を開けないこと' do
    sign_in create(:user)

    visit new_admins_subscription_order_generation_path

    expect(page).to have_content '管理者としてログインしてください。'
  end
end
