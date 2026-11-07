describe '共通レイアウト', type: :system do
  it 'ヘッダーにサイト名とナビゲーションが表示されること' do
    visit root_path

    within 'header' do
      expect(page).to have_link 'ひるどき', href: root_path
      expect(page).to have_css "nav[aria-label='メインナビゲーション']"
    end
  end

  it 'スマホ幅用のメニューボタンがあること' do
    visit root_path

    expect(page).to have_button 'メニューを開く'
  end

  it 'ページタイトルにサイト名が入ること' do
    visit root_path

    expect(page).to have_title 'ひるどき'
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
