describe '弁当詳細', type: :system do
  before do
    travel_to Time.zone.local(2026, 12, 1, 9, 0)
  end

  def create_review(daily_menu:, rating:, comment:, reviewed_at:)
    order = create(:order, daily_menu:, status: :received)
    create(:review, order:, rating:, comment:, created_at: reviewed_at)
  end

  it '献立一覧の弁当名から詳細を開くと、弁当の情報と平均評価・評価一覧が表示されること' do
    bento = create(:bento, name: '鮭の塩焼き弁当', bento_type: :japanese, price: 650, description: '国産の鮭を使っています。')
    bento.image.attach(io: file_fixture('bento.png').open, filename: 'bento.png', content_type: 'image/png')
    daily_menu = create(:daily_menu, bento:, served_on: Date.new(2026, 12, 1))
    old_review = create_review(daily_menu:, rating: 3, comment: '少し塩辛かった', reviewed_at: Time.zone.local(2026, 11, 20, 12, 0))
    new_review = create_review(daily_menu:, rating: 4, comment: 'おいしかった', reviewed_at: Time.zone.local(2026, 11, 25, 12, 0))
    sign_in create(:user)

    visit root_path
    click_link '鮭の塩焼き弁当'

    expect(page).to have_css 'h1', text: '鮭の塩焼き弁当'
    expect(page).to have_content '和食'
    expect(page).to have_content '650円 （税抜）'
    expect(page).to have_content '国産の鮭を使っています。'
    expect(page).to have_css "img[alt='鮭の塩焼き弁当']"
    expect(page).to have_css "[data-test-id='average-rating']", text: '★3.5 (2)'
    within("[data-test-id='#{dom_id(new_review)}']") do
      expect(page).to have_css "[aria-label='5段階中4']"
      expect(page).to have_content '2026/11/25'
      expect(page).to have_content 'おいしかった'
    end
    within("[data-test-id='#{dom_id(old_review)}']") do
      expect(page).to have_css "[aria-label='5段階中3']"
      expect(page).to have_content '少し塩辛かった'
    end
    expect(page.body.index('おいしかった')).to be < page.body.index('少し塩辛かった')
  end

  it '評価がないときは、その旨が表示されること' do
    bento = create(:bento)
    sign_in create(:user)

    visit bento_path(bento)

    expect(page).to have_css "[data-test-id='average-rating']", text: '評価はまだありません'
    expect(page).to have_content '評価はまだありません。'
  end

  it '販売中の弁当の詳細は表示され、非販売の弁当の詳細は表示されないこと' do
    on_sale_bento = create(:bento, name: '鮭の塩焼き弁当')
    not_on_sale_bento = create(:bento, name: '麻婆豆腐弁当', on_sale: false)
    sign_in create(:user)

    visit bento_path(on_sale_bento)
    expect(page).to have_css 'h1', text: '鮭の塩焼き弁当'

    visit bento_path(not_on_sale_bento)
    expect(page).to have_http_status :not_found
    expect(page).to have_no_css 'h1', text: '麻婆豆腐弁当'
  end

  it 'ログインしていないとログイン画面に移動すること' do
    bento = create(:bento)

    visit bento_path(bento)

    expect(page).to have_current_path new_user_session_path
  end
end
