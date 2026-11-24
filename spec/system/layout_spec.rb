describe '共通レイアウト', type: :system do
  it 'ヘッダーにサイト名とナビゲーションが表示されること' do
    visit new_user_session_path

    within 'header' do
      expect(page).to have_link 'ひるどき', href: root_path
      expect(page).to have_css "nav[aria-label='メインナビゲーション']"
    end
  end

  it 'ページタイトルにサイト名が入ること' do
    visit new_user_session_path

    expect(page).to have_title 'ログイン | ひるどき'
  end

  describe 'フラッシュメッセージ' do
    it '成功したときのメッセージが通知として表示されること' do
      user = create(:user, password: 'password123')

      visit new_user_session_path
      fill_in 'メールアドレス', with: user.email
      fill_in 'パスワード', with: 'password123'
      click_button 'ログイン'

      expect(page).to have_css "[role='alert']", text: 'ログインしました。'
    end

    it '失敗したときのメッセージが通知として表示されること' do
      visit new_user_session_path
      fill_in 'メールアドレス', with: 'nobody@example.com'
      fill_in 'パスワード', with: 'wrong-password'
      click_button 'ログイン'

      expect(page).to have_css "[role='alert']", text: 'メールアドレスまたはパスワードが違います。'
    end
  end

  describe 'ヘッダーのマイページ' do
    it '利用者のマイページでアカウント情報を確かめ、変更画面を開いてもマイページが現在地として表示されること' do
      sign_in create(:user, name: 'ひるどき 太郎', email: 'taro@example.com')

      visit root_path
      within('header') { click_link 'マイページ' }

      within("[data-test-id='account-info']") do
        expect(page).to have_content 'ひるどき 太郎'
        expect(page).to have_content 'taro@example.com'
      end

      click_link 'アカウント情報を変更する'

      expect(page).to have_css 'h1', text: 'アカウント情報の変更'
      within('header') do
        expect(page).to have_css "a[aria-current='page']", text: 'マイページ'
        expect(page).to have_no_css "a[aria-current='page']", text: '献立'
      end
    end
  end

  describe 'ナビゲーションの現在地表示' do
    it '表示中のページのリンクだけに aria-current="page" が付くこと' do
      visit new_user_session_path

      within 'header' do
        expect(page).to have_css "a[aria-current='page']", text: 'ログイン'
        expect(page).to have_no_css "a[aria-current='page']", text: '献立'
        expect(page).to have_no_css "a[aria-current='page']", text: '新規登録'
      end
    end
  end
end
