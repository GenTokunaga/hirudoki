describe '管理者のマイページ', type: :system do
  it 'ヘッダーのマイページからアカウント情報を確かめ、ログアウトできること' do
    sign_in create(:admin, name: '管理 花子', email: 'hanako@example.com'), scope: :admin

    visit admins_bentos_path
    within('header') { click_link 'マイページ' }

    within("[data-test-id='account-info']") do
      expect(page).to have_content '管理 花子'
      expect(page).to have_content 'hanako@example.com'
    end
    within('header') { expect(page).to have_css "a[aria-current='page']", text: 'マイページ' }

    click_button 'ログアウト'

    expect(page).to have_current_path new_admin_session_path
  end
end
