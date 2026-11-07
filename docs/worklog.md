# 作業ログ

技術試験「ひるどき」の作業時間の記録。制限時間は 30 時間。

## 集計

| 週 | 日付 | 作業時間 | 累計 |
|---|---|---|---|
| 第1週 | 2026-11-07 | 記入中 | - |

## 記録

記入ルール：作業の区切りごとに 1 行追加する。時間は分単位。AI に任せた作業も「担当」に書く。

### 2026-11-07（第1週）

| 開始 | 終了 | 分 | 区分 | 内容 | 担当 |
|---|---|---|---|---|---|
|  |  |  | 準備 | 仕様書を通読し、業務ルール（3章）の疑問点・解釈をメモ | 本人 |
|  |  |  | 準備 | 管理者ログインの要否と、シードのパスワード管理方針を検討（環境変数で渡す方針に決定） | 本人 + AI 相談 |
|  |  |  | 準備 | GitHub に public リポジトリを作成 | AI（Claude Code） |
|  |  |  | 環境構築 | `rails new hirudoki -d postgresql --css=bootstrap`（Rails 8.1.4 / Ruby 3.4）を実行し、Initial commit | AI（Claude Code） |
|  |  |  | 環境構築 | Heroku のアカウント作成・支払い方法の登録、画像保存先を Bucketeer に決定 | 本人 + AI 相談 |
|  |  |  | 環境構築 | タイムゾーン設定、トップページ作成、RSpec・FactoryBot・Capybara 導入、CI を RSpec に変更 | AI（Claude Code） |
|  |  |  | 環境構築 | Heroku 向け本番設定（DB を 1 つに統合、Procfile、Bucketeer 用 Active Storage、SSL）、設計判断メモ作成 | AI（Claude Code） |
|  |  |  | 環境構築 | Heroku CLI 導入、アプリ・アドオン作成、環境変数設定、初回デプロイ | 本人 |
|  |  |  | 環境構築 | Heroku の環境変数（TZ・RAILS_MASTER_KEY）設定、初回デプロイを確認 | 本人 |
|  |  |  | 共通レイアウト | ナビバー・フラッシュ・現在地表示、helper spec / system spec（PR #5） | AI（Claude Code） |
|  |  |  | 認証 | Devise で利用者・管理者の認証、日本語化、シード、model spec / system spec（PR #6） | AI（Claude Code） |
|  |  |  | DB作成 | 残り6テーブルのマイグレーション・モデル・制約、model spec（PR #7） | AI（Claude Code） |
|  |  |  | レビュー | PR #5〜#7 の内容確認・マージ | 本人 |
