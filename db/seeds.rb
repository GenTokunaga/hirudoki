# NOTE: 本番のパスワードをコードや Git の履歴に残さないため、テストアカウントは環境変数で渡す。
#       開発環境では未設定なら仮の値を使い、本番では仮の値で公開しないよう未設定ならエラーにしている。
def seed_value(key, development_default)
  ENV.fetch(key) do
    raise "環境変数 #{key} を設定してください" if Rails.env.production?

    development_default
  end
end

Admin.find_or_create_by!(email: seed_value('SEED_ADMIN_EMAIL', 'admin@example.com')) do |a|
  a.name = '管理者'
  a.password = seed_value('SEED_ADMIN_PASSWORD', 'password')
end

User.find_or_create_by!(email: seed_value('SEED_USER_EMAIL', 'user@example.com')) do |u|
  u.name = 'ひるどき 太郎'
  u.phone_number = '090-1234-5678'
  u.password = seed_value('SEED_USER_PASSWORD', 'password')
end
