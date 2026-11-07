require 'rails_helper'

RSpec.describe '管理者のログイン', type: :system do
  before do
    create(:admin, email: 'admin@example.com', password: 'password123')
  end

  it 'ログインすると管理画面に入れ、ログアウトするとログイン画面に戻る' do
    visit new_admin_session_path
    fill_in 'メールアドレス', with: 'admin@example.com'
    fill_in 'パスワード', with: 'password123'
    click_button 'ログイン'

    expect(page).to have_current_path admin_root_path
    expect(page).to have_css 'h1', text: '管理画面'

    click_button 'ログアウト'

    expect(page).to have_current_path new_admin_session_path
  end

  it 'パスワードが違うとログインできない' do
    visit new_admin_session_path
    fill_in 'メールアドレス', with: 'admin@example.com'
    fill_in 'パスワード', with: 'wrong-password'
    click_button 'ログイン'

    expect(page).to have_content 'メールアドレスまたはパスワードが違います'
    expect(page).to have_current_path new_admin_session_path
  end

  it 'ログインしていないと管理画面に入れない' do
    visit admin_root_path

    expect(page).to have_current_path new_admin_session_path
    expect(page).to have_content '管理者としてログインしてください。'
    expect(page).not_to have_content 'アカウント登録'
  end

  it '利用者としてログインしていても管理画面には入れない' do
    sign_in create(:user)

    visit admin_root_path

    expect(page).to have_current_path new_admin_session_path
  end

  it '利用者のアカウントで管理者ログインはできない' do
    create(:user, email: 'user@example.com', password: 'password123')

    visit new_admin_session_path
    fill_in 'メールアドレス', with: 'user@example.com'
    fill_in 'パスワード', with: 'password123'
    click_button 'ログイン'

    expect(page).to have_content 'メールアドレスまたはパスワードが違います'
  end

  it '管理者の登録画面はない' do
    visit '/admin/sign_up'

    expect(page).to have_http_status(:not_found)
  end
end
