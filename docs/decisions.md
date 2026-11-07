# 設計判断メモ

技術面談で「なぜそうしたか・他の案は検討したか」を説明するための記録。

| 日付 | テーマ | 選んだ案 | 他の案 | 選んだ理由 |
|---|---|---|---|---|
| 2026-11-07 | 管理者のログイン | 管理者はログイン画面のみ用意し、登録画面は作らない。アカウントはシードで作る | 管理者も画面から登録できるようにする | 仕様に「管理者アカウントは画面からは作成しない。シードデータで用意する」とあり、DB 設計にもパスワード（ハッシュ化）がある。管理機能を守るためログインは必要 |
| 2026-11-07 | シードのパスワード | 環境変数（`SEED_ADMIN_PASSWORD` など）から読む。開発環境では仮の値、本番では未設定ならエラー | seeds.rb に直接書く / Rails credentials に入れる | 本番のパスワードをコードと Git 履歴に残さないため。credentials は master key の管理が別に必要になり、Heroku では環境変数が標準 |
| 2026-11-07 | タイムゾーン | `config.time_zone = "Tokyo"`、Heroku 側も `TZ=Asia/Tokyo` | UTC のまま、表示時だけ変換する | 締切「提供日当日 10:00」を日本時間で判定する業務ルールのため。時刻の取得は `Time.current` に統一する |
| 2026-11-07 | テストフレームワーク | RSpec + FactoryBot + Capybara。Minitest の `test/` は削除 | Minitest と併用 | 課題の要件が「system spec および model spec」のため。2 つのフレームワークを混在させない |
| 2026-11-07 | system spec のドライバ | 通常は `rack_test`、`js: true` のときだけヘッドレス Chrome | 全て Chrome で動かす | JavaScript が不要な画面は rack_test の方が速く安定する |
| 2026-11-07 | 本番の DB 構成 | Heroku Postgres 1 つ（`DATABASE_URL`）。キャッシュは `memory_store`、ジョブは `async`、ActionCable は `async`。Solid Cache / Queue / Cable は削除 | Rails 8 標準どおり DB を 4 つに分ける / 1 つの DB に Solid 系のテーブルを同居させる | Heroku Postgres は 1 アプリ 1 DB で、追加 DB は費用がかかる。Dyno 1 台構成なので、プロセス内のキャッシュとジョブで足りる。Solid Queue を使うなら worker Dyno も必要になる |
| 2026-11-07 | 画像の保存先 | Active Storage + Bucketeer（Heroku アドオンの Amazon S3） | Cloudcube / Cloudflare R2 / Cloudinary | Heroku はファイルが Dyno 再起動で消える。Bucketeer は別アカウントが不要で、接続情報が環境変数に自動で入る。Heroku 公式の Active Storage ガイドも Bucketeer 前提 |
| 2026-11-07 | HTTPS | `assume_ssl` と `force_ssl` を有効化 | 無効のまま | Heroku のルーターが SSL を終端するため。Cookie を Secure にし、http アクセスを https に寄せる |
