require "rails_helper"

RSpec.describe "利用者の登録・ログイン", type: :system do
  def fill_in_sign_up_form(email: "taro@example.com", phone_number: "090-1234-5678")
    fill_in "氏名", with: "ひるどき 太郎"
    fill_in "メールアドレス", with: email
    fill_in "電話番号", with: phone_number
    fill_in "パスワード", with: "password123"
    fill_in "パスワード（確認）", with: "password123"
  end

  it "登録 → ログアウト → ログインができる" do
    visit new_user_registration_path
    fill_in_sign_up_form
    click_button "登録する"

    expect(page).to have_current_path root_path
    expect(page).to have_button "ログアウト"

    click_button "ログアウト"
    expect(page).to have_link "ログイン"

    click_link "ログイン"
    fill_in "メールアドレス", with: "taro@example.com"
    fill_in "パスワード", with: "password123"
    click_button "ログイン"

    expect(page).to have_content "ログインしました"
    expect(page).to have_link "アカウント"
  end

  it "入力に誤りがあると登録できず、エラーが表示される" do
    visit new_user_registration_path
    fill_in_sign_up_form(phone_number: "123")
    click_button "登録する"

    expect(page).to have_content "電話番号は不正な値です"
    expect(User.count).to eq 0
  end

  it "登録済みのメールアドレスでは登録できない" do
    create(:user, email: "taro@example.com")

    visit new_user_registration_path
    fill_in_sign_up_form(email: "taro@example.com")
    click_button "登録する"

    expect(page).to have_content "メールアドレスはすでに存在します"
  end

  it "パスワードが違うとログインできない" do
    create(:user, email: "taro@example.com", password: "password123")

    visit new_user_session_path
    fill_in "メールアドレス", with: "taro@example.com"
    fill_in "パスワード", with: "wrong-password"
    click_button "ログイン"

    expect(page).to have_content "メールアドレスまたはパスワードが違います"
    expect(page).not_to have_button "ログアウト"
  end

  it "アカウント情報を変更できる" do
    user = create(:user, password: "password123")
    sign_in user

    visit edit_user_registration_path
    fill_in "電話番号", with: "03-1234-5678"
    fill_in "現在のパスワード", with: "password123"
    click_button "保存する"

    expect(page).to have_content "アカウント情報を変更しました"
    expect(user.reload.phone_number).to eq "03-1234-5678"
  end

  it "退会（アカウント削除）の機能はない" do
    expect { Rails.application.routes.recognize_path("/users", method: :delete) }
      .to raise_error(ActionController::RoutingError)
  end
end
