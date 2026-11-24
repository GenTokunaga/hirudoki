describe '評価の投稿', type: :system do
  before do
    travel_to Time.zone.local(2026, 12, 3, 12, 0)
  end

  it '受取済みの注文に評価を投稿すると、注文の詳細と弁当の詳細に表示されること' do
    user = create(:user)
    bento = create(:bento, name: '鮭の塩焼き弁当')
    order = create(:order, :received, user:, daily_menu: create(:daily_menu, bento:, served_on: Date.new(2026, 12, 2)))
    sign_in user

    visit order_path(order)
    click_link '評価を投稿する'
    choose '★★★★☆（4）'
    fill_in 'コメント', with: '鮭の焼き加減がちょうどよかったです。'
    click_button '投稿する'

    expect(page).to have_content '評価を投稿しました。'
    within("[data-test-id='order-review']") do
      expect(page).to have_css "[aria-label='5段階中4']"
      expect(page).to have_content '鮭の焼き加減がちょうどよかったです。'
      expect(page).to have_no_link '評価を投稿する'
    end

    click_link '鮭の塩焼き弁当'

    expect(page).to have_css "[data-test-id='average-rating']", text: '★4.0 (1)'
    expect(page).to have_content '鮭の焼き加減がちょうどよかったです。'
  end

  it '受取前の注文は、評価の投稿ボタンが押せず理由が表示されること' do
    user = create(:user)
    order = create(:order, user:, daily_menu: create(:daily_menu, served_on: Date.new(2026, 12, 4)))
    sign_in user

    visit order_path(order)

    within("[data-test-id='order-review']") do
      expect(page).to have_button '評価を投稿する', disabled: true
      expect(page).to have_content '評価は、弁当を受け取った後（受取済みになった注文）に投稿できます。'
    end
  end

  it '評価を選ばずに投稿すると、エラーが表示されること' do
    user = create(:user)
    order = create(:order, :received, user:)
    sign_in user

    visit new_order_review_path(order)
    click_button '投稿する'

    expect(page).to have_content '入力内容に誤りがあります。'
    expect(page).to have_content '評価を入力してください'
    expect(order.reload.review).to be_nil
  end

  it '投稿画面を開いた後に注文が受取済みでなくなると、理由だけが表示されて投稿されないこと' do
    user = create(:user)
    order = create(:order, :received, user:)
    sign_in user

    visit new_order_review_path(order)
    choose '★★★★☆（4）'
    order.update!(status: :ordered)
    click_button '投稿する'

    expect(page).to have_content '評価は、受取済みの注文にだけ投稿できます'
    expect(page).to have_no_content '入力内容に誤りがあります。'
    expect(order.reload.review).to be_nil
  end

  it '評価を投稿済みの注文で投稿画面を開くと、注文の詳細に戻され理由が表示されること' do
    user = create(:user)
    order = create(:order, :received, user:)
    create(:review, order:)
    sign_in user

    visit new_order_review_path(order)

    expect(page).to have_current_path order_path(order)
    expect(page).to have_content 'この注文には、すでに評価を投稿しています。'
  end
end
