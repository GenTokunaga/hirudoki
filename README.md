# ひるどき

日替わりの弁当を注文すると、自宅やオフィスまで届けてくれる宅配サイトです。
利用者はその日の献立を見て注文し、管理者は献立・注文・配達を管理します。

## 稼働環境

- URL：https://hirudoki-gen-faf975970d1d.herokuapp.com/
- テストアカウント

| 種別 | ログイン画面 | メールアドレス | パスワード |
|---|---|---|---|
| 管理者 | `/admins/sign_in` | admin@example.com | 提出時にお知らせします |
| 利用者 | `/users/sign_in` | user@example.com | 提出時にお知らせします |

本番のパスワードをコードや Git の履歴に残さないため、パスワードは README に書いていません。シードは環境変数 `SEED_ADMIN_EMAIL` / `SEED_ADMIN_PASSWORD` / `SEED_USER_EMAIL` / `SEED_USER_PASSWORD` からアカウントを作ります（本番で未設定ならエラー）。

## 主な機能

| 利用者 | 管理者（`/admins`） |
|---|---|
| 会員登録・ログイン | ログイン（アカウントはシードで作成） |
| 献立一覧（提供日・弁当タイプで絞り込み）・弁当詳細（平均評価・評価一覧） | 弁当の登録・編集・削除・販売／非販売の切替（画像 1 枚） |
| 注文（当日 10:00 締切、14 日先まで、1 人 1 日 3 個まで） | 配達エリアの登録・編集・有効／無効の切替・削除 |
| マイページ（注文履歴・アカウント情報の変更） | 日別献立の登録・編集・削除 |
| 締切前の個数変更・キャンセル | 注文の一覧・詳細・ステータス変更 |
| 受取済みの注文の評価 | 定期注文の生成（対象日を指定して手動実行） |
| 定期注文の設定（曜日ごと、1 個あたり 50 円引き） | 製造・配達リスト、利用者の一覧・詳細・月ごとの請求額 |

## 技術構成

- Ruby 3.4.13 / Rails 8.1 / PostgreSQL
- ビュー：Haml、Bootstrap（cssbundling-rails）、simple_form
- 認証：Devise（利用者 `User` と管理者 `Admin` を別モデル・別セッションに分ける）
- 画像：Active Storage（本番は外部ストレージ）
- テスト：RSpec（model spec / system spec）、FactoryBot、Capybara
- 静的解析：RuboCop（sgcop）、haml-lint、Brakeman
- デプロイ：Heroku（`Procfile` の `release` でマイグレーション）

## セットアップ

```bash
bundle install
yarn install
bin/rails db:prepare   # DB 作成・マイグレーション・シード
bin/dev                # http://localhost:3000
```

開発環境のシードは、環境変数がなければ次のアカウントを作ります。

| 種別 | メールアドレス | パスワード |
|---|---|---|
| 管理者 | admin@example.com | password |
| 利用者 | user@example.com | password |

シードは何度流しても壊れないよう `find_or_create_by!` で作り、次のデータを入れます。

- 4 タイプ × 2 種類の弁当（画像付き）と非販売の弁当 1 件、配達エリア 5 件（うち無効 1 件）
- 当月 1 日〜翌月末の毎日、4 タイプの献立
- 定期注文設定（無効のもの・生成すると 1 日 3 個を超えてスキップされるものを含む）
- 注文（受取済み・評価付き、注文済み、キャンセル済み）

## テスト・静的解析

```bash
bundle exec rspec
bundle exec rubocop
bundle exec haml-lint app
bin/brakeman
```

## テーブル

仕様書のテーブル（利用者・管理者・弁当・配達エリア・日別献立・注文・定期注文設定・評価）に加えて、追加したのは Active Storage のテーブル（`active_storage_*`）だけです。弁当の画像を外部ストレージに保存するために使っています。
残数はカラムを持たず、注文の個数から算出しています。

## ドキュメント

- [`docs/decisions.md`](docs/decisions.md)：設計判断メモ（選んだ案・他の案・選んだ理由）
- [`docs/worklog.md`](docs/worklog.md)：作業ログ
