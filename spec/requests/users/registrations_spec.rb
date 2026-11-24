describe '利用者の退会', type: :request do
  it 'ログイン中に DELETE /users を送っても 404 が返り、利用者は削除されないこと' do
    user = create(:user)
    sign_in user

    delete user_registration_path

    expect(response).to have_http_status :not_found
    expect(User.exists?(user.id)).to be true
  end
end
