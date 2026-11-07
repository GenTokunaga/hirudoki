# 作業ログ

技術試験「ひるどき」の作業時間の記録。制限時間は 30 時間。

## 集計

| 週 | 日付 | 作業時間 | 累計 |
|---|---|---|---|
| 第1週 | 2026-11-07 | 5時間30分 | 5時間30分 |

## 記録

記入ルール：作業の区切りごとに 1 行追加する。作業時間は日ごとの合計だけを記録する。AI に任せた作業も「担当」に書く。

### 2026-11-07（第1週）

10:30〜18:00（休憩 2 時間）、実働 5 時間 30 分（330 分）。各作業の細かい時間は省略。

| 区分 | 内容 | 担当 |
|---|---|---|
| 準備 | 仕様書を通読し、業務ルール（3章）の疑問点・解釈をメモ | 本人 |
| 準備 | 管理者ログインの要否と、シードのパスワード管理方針を検討（環境変数で渡す方針に決定） | 本人 + AI 相談 |
| 準備 | GitHub に public リポジトリを作成 | AI（Claude Code） |
| 環境構築 | `rails new hirudoki -d postgresql --css=bootstrap`（Rails 8.1.4 / Ruby 3.4）を実行し、Initial commit | AI（Claude Code） |
| 環境構築 | Heroku のアカウント作成・支払い方法の登録、画像保存先を Bucketeer に決定 | 本人 + AI 相談 |
| 環境構築 | タイムゾーン設定、トップページ作成、RSpec・FactoryBot・Capybara 導入、CI を RSpec に変更 | AI（Claude Code） |
| 環境構築 | Heroku 向け本番設定（DB を 1 つに統合、Procfile、Bucketeer 用 Active Storage、SSL）、設計判断メモ作成 | AI（Claude Code） |
| 環境構築 | Claude Code のルールと設定を追加 | AI（Claude Code） |
| 環境構築 | RuboCop の設定を sgcop に変更し、警告を修正 | AI（Claude Code） |
| 環境構築 | Dependabot の PR（GitHub Actions の更新 3 件）をマージ、image_processing を削除 | 本人 + AI（Claude Code） |
| 環境構築 | Heroku CLI 導入、アプリ・アドオン作成、環境変数設定、初回デプロイ | 本人 |
| 環境構築 | Heroku の環境変数（TZ・RAILS_MASTER_KEY）設定、初回デプロイを確認 | 本人 |
| 環境構築 | ビューを Haml に変換（html2haml）、.rspec・haml-lint の設定、コメントとルーティングのルールを .claude に追加 | AI（Claude Code） |
| 共通レイアウト | ナビバー（スマホではハンバーガー）・フラッシュメッセージ・現在地表示（PR #5） | AI（Claude Code） |
| 認証 | Devise で利用者・管理者の認証、ルーティングを resource で定義、管理画面を admins/ に、simple_form 導入（PR #6） | AI（Claude Code） |
| DB作成 | 残り 6 テーブルのマイグレーション・モデル・制約（PR #7 → #11 で main に反映） | AI（Claude Code） |
| レビュー | PR #5〜#7・#9〜#12 のレビュー（コメント整理、命名・ルーティング・不要なルートやファイルの削除など）とマージ | 本人 + AI（Claude Code） |
| テスト | RSpec を .claude/rules に沿って見直し、単純なバリデーションのテストを削除（PR #12） | AI（Claude Code） |
| デプロイ | 最新の main を Heroku にデプロイ（v8）、テストアカウントのシードを投入して動作確認 | 本人 + AI（Claude Code） |
