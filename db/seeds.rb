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

user = User.find_or_create_by!(email: seed_value('SEED_USER_EMAIL', 'user@example.com')) do |u|
  u.name = 'ひるどき 太郎'
  u.phone_number = '090-1234-5678'
  u.password = seed_value('SEED_USER_PASSWORD', 'password')
end

bento_attributes = [
  { name: '鮭の塩焼き弁当', bento_type: :japanese, price: 650, description: '脂ののった鮭を塩焼きにし、ひじきの煮物と卵焼きを添えました。' },
  { name: '肉じゃが弁当', bento_type: :japanese, price: 620, description: '甘辛く煮た肉じゃがに、ほうれん草のおひたしを合わせました。' },
  { name: 'ハンバーグ弁当', bento_type: :western, price: 700, description: 'デミグラスソースのハンバーグに、ポテトサラダを添えました。' },
  { name: 'チキン南蛮弁当', bento_type: :western, price: 680, description: '甘酢にくぐらせたチキンに、自家製のタルタルソースをかけました。' },
  { name: '麻婆豆腐弁当', bento_type: :chinese, price: 640, description: '山椒の効いた麻婆豆腐に、春雨サラダを合わせました。' },
  { name: '酢豚弁当', bento_type: :chinese, price: 660, description: '野菜たっぷりの酢豚に、中華風の卵スープの具を添えました。' },
  { name: '彩り野菜弁当', bento_type: :healthy, price: 720, description: '10 種類の野菜と雑穀米で、500kcal 以下に抑えました。' },
  { name: '鶏むね肉のグリル弁当', bento_type: :healthy, price: 740, description: '鶏むね肉のハーブグリルと、玄米・温野菜の組み合わせです。' },
]

bentos = bento_attributes.each_with_index.map do |attributes, index|
  bento = Bento.find_or_create_by!(name: attributes[:name]) do |b|
    b.assign_attributes(attributes.merge(position: index + 1))
  end
  unless bento.image.attached?
    image_path = Rails.root.join("db/seeds/images/#{bento.bento_type}.png")
    bento.image.attach(io: File.open(image_path), filename: "#{bento.bento_type}.png", content_type: 'image/png')
  end
  bento
end

Bento.find_or_create_by!(name: '松茸ご飯弁当（季節限定）') do |b|
  b.assign_attributes(bento_type: :japanese, price: 1_200, position: bento_attributes.size + 1, on_sale: false,
                      description: '秋の季節限定の弁当です。販売期間が終わったため非販売にしています。')
end

[
  { name: '渋谷区神南', postal_code: '1500041' },
  { name: '渋谷区宇田川町', postal_code: '1500042' },
  { name: '渋谷区道玄坂', postal_code: '1500043' },
  { name: '渋谷区桜丘町', postal_code: '1500031' },
  { name: '渋谷区代々木', postal_code: '1510053', active: false },
].each do |attributes|
  DeliveryArea.find_or_create_by!(postal_code: attributes[:postal_code]) { it.assign_attributes(attributes) }
end

bentos_by_type = bentos.group_by(&:bento_type)
(Date.current.beginning_of_month..Date.current.next_month.end_of_month).each do |served_on|
  bentos_by_type.each do |bento_type, bentos_of_type|
    # NOTE: 献立は「同じ提供日に同じ弁当タイプは1件まで」。手で登録した献立や、管理画面で弁当を変えた献立があっても
    #       止まらずに何度でも流せるよう、（提供日, 弁当）ではなく（提供日, 弁当タイプ）で有無を確かめている
    next if DailyMenu.joins(:bento).exists?(served_on:, bentos: { bento_type: })

    DailyMenu.create!(served_on:, bento: bentos_of_type[served_on.day % bentos_of_type.size], stock_limit: 20)
  end
end

reviewed_bento = Bento.find_by!(name: '鮭の塩焼き弁当')
delivery_area = DeliveryArea.find_by!(postal_code: '1500041')
[
  { rating: 5, comment: "鮭の焼き加減がちょうどよく、ご飯が進みました。\nまた注文します。", posted_at: '12:45' },
  { rating: 4, comment: '副菜の卵焼きが甘めで好みでした。', posted_at: '18:20' },
  { rating: 4, comment: '', posted_at: '13:10' },
].zip(DailyMenu.where(bento: reviewed_bento, served_on: ...Date.current).order(:served_on)).each do |review_attributes, daily_menu|
  # NOTE: 月の初めは提供済みの献立が 3 日分ないため、ある分だけ評価を作る
  break if daily_menu.nil?

  # NOTE: 評価一覧の並び順（新しい順）を画面で確かめられるよう、受け取った日の昼〜夜に投稿した日時にしている
  posted_at = Time.zone.parse("#{daily_menu.served_on} #{review_attributes[:posted_at]}")

  order = Order.find_or_create_by!(user:, daily_menu:) do |o|
    # TODO: 料金計算（PR #43）がマージされたら、合計金額は Order#assign_total_price で計算する
    total_price = reviewed_bento.price * (100 + Rails.configuration.x.hirudoki.tax_rate_percent) / 100
    o.assign_attributes(delivery_area:, delivery_address: '東京都渋谷区神南1-1-1', quantity: 1, status: :received,
                        unit_price: reviewed_bento.price, discount_per_unit: 0, total_price:)
  end
  Review.find_or_create_by!(order:) do |review|
    review.assign_attributes(review_attributes.slice(:rating, :comment).merge(created_at: posted_at, updated_at: posted_at))
  end
end
