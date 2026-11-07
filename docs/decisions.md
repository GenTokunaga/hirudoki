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
| 2026-11-07 | 認証ライブラリ | Devise（利用者 User・管理者 Admin を別モデル・別セッション） | `has_secure_password` で自作 / 1 つの User モデルに管理者フラグ | パスワードのハッシュ化・セッション管理・Remember me を実績のある実装に任せる。仕様の DB 設計で利用者と管理者が別テーブルのため、Devise のスコープも分けた。利用者でログインしていても管理画面には入れない |
| 2026-11-07 | Devise のモジュール | 利用者：database_authenticatable / registerable / rememberable / validatable。管理者は registerable なし | recoverable（パスワード再設定）や confirmable（メール確認）も入れる | どちらもメール送信が必要で、通知全般が課題の対象外。管理者は「画面からは作成しない」仕様 |
| 2026-11-07 | 退会 | 利用者登録のルートを個別に定義し、`DELETE /users`（退会）を作らない | Devise 標準のまま退会ボタンだけ隠す | 退会は対象外。画面から隠すだけだとリクエストを直接送れば消せてしまう |
| 2026-11-07 | 電話番号の形式 | 数字 10〜11 桁、またはハイフン区切り | 形式チェックなし / 国際形式まで許可 | 配達時の連絡先として日本の固定電話・携帯を想定。異常値を弾くことが評価対象 |
| 2026-11-07 | 日本語化 | `rails-i18n` と `devise-i18n` を導入し、既定ロケールを ja に | 自前で全メッセージを翻訳 | エラーメッセージを利用者に分かる言葉で出すため。標準の翻訳を使い、項目名だけ `config/locales/ja.yml` で定義 |
| 2026-11-07 | 管理画面の namespace | `Admins::`（`app/controllers/admins/`）、基底は `Admins::ApplicationController`。URL は `/admin` のまま | `Admin::BaseController`（当初の実装） | プロジェクトのルール（`.claude/rules`）に合わせた。`Admin` モデルと名前が重ならず、Devise の管理者ビュー（`app/views/admins/sessions`）とも同じ場所にまとまる。URL は Devise のログイン画面 `/admin/sign_in` とそろえるため `path: 'admin'` で変えない |
