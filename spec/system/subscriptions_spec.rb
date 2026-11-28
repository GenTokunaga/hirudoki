describe '定期注文の設定', type: :system do
  it 'マイページから登録し、編集して無効にできること' do
    user = create(:user)
    create(:delivery_area, name: '渋谷区神南', postal_code: '1500041')
    create(:delivery_area, name: '渋谷区道玄坂', postal_code: '1500043')
    sign_in user

    visit mypage_path
    click_link '定期注文を確認する'
    expect(page).to have_content '登録されている定期注文はありません。'
    click_link '定期注文を登録'

    select '水曜日', from: '曜日'
    select 'ヘルシー', from: '弁当タイプ'
    select '2 個', from: '個数'
    select '渋谷区神南（〒150-0041）', from: '配達エリア'
    fill_in '配達先住所', with: '東京都渋谷区神南1-1-1'
    click_button '登録する'

    expect(page).to have_content '水曜日の定期注文を登録しました。'
    subscription = user.subscriptions.find_by!(wday: 3)
    within "[data-test-id='#{dom_id(subscription)}']" do
      expect(page).to have_content 'ヘルシー'
      expect(page).to have_content '2 個'
      expect(page).to have_content '渋谷区神南'
      expect(page).to have_content '有効'
      click_link '水曜日'
    end

    expect(page).to have_css "a[aria-current='page']", text: 'マイページ'
    select '和食', from: '弁当タイプ'
    select '渋谷区道玄坂（〒150-0043）', from: '配達エリア'
    uncheck '有効にする'
    click_button '更新する'

    expect(page).to have_content '水曜日の定期注文を更新しました。'
    within "[data-test-id='#{dom_id(subscription)}']" do
      expect(page).to have_content '和食'
      expect(page).to have_content '渋谷区道玄坂'
      expect(page).to have_content '無効'
    end
  end

  it '曜日の選択肢は月曜日から金曜日までで、土日は出ないこと' do
    sign_in create(:user)

    visit new_subscription_path

    expect(page).to have_select '曜日', options: %w[選択してください 月曜日 火曜日 水曜日 木曜日 金曜日]
  end

  it '登録済みの曜日は 2 件目として登録できないこと' do
    user = create(:user)
    create(:subscription, user:, wday: 1)
    create(:delivery_area, name: '渋谷区神南', postal_code: '1500041')
    sign_in user

    visit new_subscription_path
    select '月曜日', from: '曜日'
    select '和食', from: '弁当タイプ'
    select '1 個', from: '個数'
    select '渋谷区神南（〒150-0041）', from: '配達エリア'
    fill_in '配達先住所', with: '東京都渋谷区神南1-1-1'
    click_button '登録する'

    expect(page).to have_content '曜日の定期注文設定はすでに登録されています。登録済みの設定を編集してください'
    expect(user.subscriptions.count).to eq 1
  end

  it '登録後にエリアが無効になっても、エリアを選び直さずに他の項目を変更できること' do
    user = create(:user)
    delivery_area = create(:delivery_area, name: '渋谷区神南', postal_code: '1500041')
    subscription = create(:subscription, user:, wday: 2, delivery_area:, quantity: 1)
    delivery_area.update!(active: false)
    sign_in user

    visit edit_subscription_path(subscription)
    expect(page).to have_select '配達エリア', selected: '渋谷区神南（〒150-0041）※無効'
    select '2 個', from: '個数'
    click_button '更新する'

    expect(page).to have_content '火曜日の定期注文を更新しました。'
    within("[data-test-id='#{dom_id(subscription)}']") { expect(page).to have_content '2 個' }
  end

  it '他の利用者の定期注文は編集できないこと' do
    other_subscription = create(:subscription)
    sign_in create(:user)

    visit edit_subscription_path(other_subscription)

    expect(page).to have_http_status :not_found
  end
end
