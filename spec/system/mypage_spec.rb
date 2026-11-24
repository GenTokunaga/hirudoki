describe 'マイページ', type: :system do
  before do
    travel_to Time.zone.local(2026, 12, 1, 9, 0)
  end

  it '自分の注文だけが提供日の新しい順に表示され、注文の詳細を開けること' do
    user = create(:user)
    older_order = create(:order, user:, daily_menu: create(:daily_menu, bento: create(:bento, name: '鮭の塩焼き弁当'), served_on: Date.new(2026, 12, 2)))
    newer_order = create(:order, user:, daily_menu: create(:daily_menu, bento: create(:bento, name: 'ハンバーグ弁当'), served_on: Date.new(2026, 12, 3)),
                                 quantity: 2, total_price: 1296)
    create(:order, daily_menu: create(:daily_menu, bento: create(:bento, name: '麻婆豆腐弁当'), served_on: Date.new(2026, 12, 4)))
    sign_in user

    visit root_path
    click_link 'マイページ'

    expect(page).to have_content '鮭の塩焼き弁当'
    expect(page).to have_no_content '麻婆豆腐弁当'
    expect(page.body.index(dom_id(newer_order))).to be < page.body.index(dom_id(older_order))
    within("[data-test-id='#{dom_id(newer_order)}']") do
      expect(page).to have_content 'ハンバーグ弁当'
      expect(page).to have_content '2 個'
      expect(page).to have_content '1,296円'
      expect(page).to have_content '注文済'
      click_link '12/3(木)'
    end

    expect(page).to have_css 'h1', text: '注文の詳細'
    expect(page).to have_content 'ハンバーグ弁当'
  end

  it '自分の注文の詳細は見られ、他の利用者の注文の詳細は見られないこと' do
    user = create(:user)
    own_order = create(:order, user:)
    other_order = create(:order)
    sign_in user

    visit order_path(own_order)
    expect(page).to have_css 'h1', text: '注文の詳細'

    visit order_path(other_order)
    expect(page).to have_http_status :not_found
  end

  it '注文がないときは、その旨が表示されること' do
    sign_in create(:user)

    visit mypage_path

    expect(page).to have_content 'まだ注文はありません。'
  end

  it 'アカウント情報を変更すると、マイページに変更後の内容が表示されること' do
    sign_in create(:user, name: 'ひるどき 太郎', password: 'password123')

    visit mypage_path
    click_link 'アカウント情報を変更する'
    fill_in '氏名', with: 'ひるどき 花子'
    fill_in '電話番号', with: '03-1234-5678'
    fill_in '現在のパスワード', with: 'password123'
    click_button '保存する'

    expect(page).to have_current_path mypage_path
    expect(page).to have_content 'アカウント情報を変更しました。'
    within("[data-test-id='account-info']") do
      expect(page).to have_content 'ひるどき 花子'
      expect(page).to have_content '03-1234-5678'
    end
  end

  it 'ログインしていないとログイン画面に移動すること' do
    visit mypage_path

    expect(page).to have_current_path new_user_session_path
  end
end
