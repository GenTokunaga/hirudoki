describe '管理者のログイン', type: :system do
  before do
    create(:admin, email: 'admin@example.com', password: 'password123')
  end

  it 'ログインすると管理画面に入れ、ログアウトするとログイン画面に戻ること' do
    visit new_admin_session_path
    fill_in 'メールアドレス', with: 'admin@example.com'
    fill_in 'パスワード', with: 'password123'
    click_button 'ログイン'

    expect(page).to have_current_path admins_dashboard_path
    expect(page).to have_css 'h1', text: '管理画面'

    click_button 'ログアウト'

    expect(page).to have_current_path new_admin_session_path
  end

  it 'パスワードが違うとログインできないこと' do
    visit new_admin_session_path
    fill_in 'メールアドレス', with: 'admin@example.com'
    fill_in 'パスワード', with: 'wrong-password'
    click_button 'ログイン'

    expect(page).to have_content 'メールアドレスまたはパスワードが違います'
    expect(page).to have_current_path new_admin_session_path
  end

  it '利用者のアカウントでは管理者としてログインできないこと' do
    create(:user, email: 'user@example.com', password: 'password123')

    visit new_admin_session_path
    fill_in 'メールアドレス', with: 'user@example.com'
    fill_in 'パスワード', with: 'password123'
    click_button 'ログイン'

    expect(page).to have_content 'メールアドレスまたはパスワードが違います'
  end

  it '管理者の登録画面はないこと' do
    visit '/admins/sign_up'

    expect(page).to have_http_status(:not_found)
  end

  describe '管理画面へのアクセス制限' do
    context 'ログインしていない場合' do
      it '管理者のログイン画面に移動し、管理者としてのログインを促されること' do
        visit admins_dashboard_path

        expect(page).to have_current_path new_admin_session_path
        expect(page).to have_content '管理者としてログインしてください。'
      end
    end

    context '利用者としてログインしている場合' do
      it '管理者のログイン画面に移動すること' do
        sign_in create(:user)

        visit admins_dashboard_path

        expect(page).to have_current_path new_admin_session_path
      end
    end
  end
end
