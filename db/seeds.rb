# 動作確認用のシードデータ。何度実行しても同じ状態になるようにする。
#
# テストアカウントのメールアドレス・パスワードは環境変数で渡す。
# 本番のパスワードをコードや Git の履歴に残さないため。
#   開発環境：未設定なら下の仮の値を使う
#   本番環境：未設定ならエラーにする（heroku config:set で設定してから db:seed を実行する）
def seed_value(key, development_default)
  ENV.fetch(key) do
    raise "環境変数 #{key} を設定してください" if Rails.env.production?

    development_default
  end
end

admin = Admin.find_or_create_by!(email: seed_value("SEED_ADMIN_EMAIL", "admin@example.com")) do |a|
  a.name = "管理者"
  a.password = seed_value("SEED_ADMIN_PASSWORD", "password")
end

user = User.find_or_create_by!(email: seed_value("SEED_USER_EMAIL", "user@example.com")) do |u|
  u.name = "ひるどき 太郎"
  u.phone_number = "090-1234-5678"
  u.password = seed_value("SEED_USER_PASSWORD", "password")
end

puts "管理者: #{admin.email}"
puts "利用者: #{user.email}"
