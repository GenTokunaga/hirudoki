# 作業ログ

技術試験「ひるどき」の作業時間の記録。制限時間は 30 時間。

## 集計

| 週 | 日付 | 作業時間 | 累計 |
|---|---|---|---|
| 第1週 | 2026-11-07 | 5時間30分 | 5時間30分 |
| 第2週 | 2026-11-15 | 6時間 | 11時間30分 |

## 記録

記入ルール：作業の区切りごとに 1 行追加し、末尾の「作業時間」にその作業にかかった時間を書く。各行の合計がその日の実働時間と一致するようにする。AI に任せた作業も「担当」に書く。

### 2026-11-07（第1週）

10:30〜18:00（休憩 2 時間）、実働 5 時間 30 分（330 分）。各作業の時間は振り返っての概算。

| 区分 | 内容 | 担当 | 作業時間 |
|---|---|---|---|
| 準備 | 仕様書を通読し、業務ルール（3章）の疑問点・解釈をメモ | 本人 | 30分 |
| 準備 | 管理者ログインの要否と、シードのパスワード管理方針を検討（環境変数で渡す方針に決定） | 本人 + AI 相談 | 15分 |
| 準備 | GitHub に public リポジトリを作成 | AI（Claude Code） | 5分 |
| 環境構築 | `rails new hirudoki -d postgresql --css=bootstrap`（Rails 8.1.4 / Ruby 3.4）を実行し、Initial commit | AI（Claude Code） | 10分 |
| 環境構築 | Heroku のアカウント作成・支払い方法の登録、画像保存先を Bucketeer に決定 | 本人 + AI 相談 | 20分 |
| 環境構築 | タイムゾーン設定、トップページ作成、RSpec・FactoryBot・Capybara 導入、CI を RSpec に変更 | AI（Claude Code） | 15分 |
| 環境構築 | Heroku 向け本番設定（DB を 1 つに統合、Procfile、Bucketeer 用 Active Storage、SSL）、設計判断メモ作成 | AI（Claude Code） | 20分 |
| 環境構築 | Claude Code のルールと設定を追加 | AI（Claude Code） | 10分 |
| 環境構築 | RuboCop の設定を sgcop に変更し、警告を修正 | AI（Claude Code） | 15分 |
| 環境構築 | Dependabot の PR（GitHub Actions の更新 3 件）をマージ、image_processing を削除 | 本人 + AI（Claude Code） | 10分 |
| 環境構築 | Heroku CLI 導入、アプリ・アドオン作成、環境変数設定、初回デプロイ | 本人 | 25分 |
| 環境構築 | Heroku の環境変数（TZ・RAILS_MASTER_KEY）設定、初回デプロイを確認 | 本人 | 10分 |
| 環境構築 | ビューを Haml に変換（html2haml）、.rspec・haml-lint の設定、コメントとルーティングのルールを .claude に追加 | AI（Claude Code） | 20分 |
| 共通レイアウト | ナビバー（スマホではハンバーガー）・フラッシュメッセージ・現在地表示（PR #5） | AI（Claude Code） | 25分 |
| 認証 | Devise で利用者・管理者の認証、ルーティングを resource で定義、管理画面を admins/ に、simple_form 導入（PR #6） | AI（Claude Code） | 30分 |
| DB作成 | 残り 6 テーブルのマイグレーション・モデル・制約（PR #7 → #11 で main に反映） | AI（Claude Code） | 25分 |
| レビュー | PR #5〜#7・#9〜#12 のレビュー（コメント整理、命名・ルーティング・不要なルートやファイルの削除など）とマージ | 本人 + AI（Claude Code） | 30分 |
| テスト | RSpec を .claude/rules に沿って見直し、単純なバリデーションのテストを削除（PR #12） | AI（Claude Code） | 10分 |
| デプロイ | 最新の main を Heroku にデプロイ（v8）、テストアカウントのシードを投入して動作確認 | 本人 + AI（Claude Code） | 5分 |

### 2026-11-15（第2週）

実働 6 時間（360 分）。各作業の時間は振り返っての概算。利用者側の献立一覧・弁当詳細、料金計算、シード追加とデプロイは次回に回した。

| 区分 | 内容 | 担当 | 作業時間 |
|---|---|---|---|
| 準備 | マージ済み worktree の削除、main の最新化、仕様書と Notion の第2週の課題を確認 | 本人 + AI（Claude Code） | 20分 |
| 作業ログ | 作業ログの表を「作業時間」列の形式に変更（PR #17） | 本人 + AI（Claude Code） | 10分 |
| 設定値 | 消費税率・定期割引・締切・注文可能日数を config/hirudoki.yml にまとめる（PR #18） | AI（Claude Code） | 15分 |
| 弁当管理 | 弁当の登録・編集・削除、販売切替、画像の形式・大きさチェック、ナビの現在地表示の改善（PR #19） | AI（Claude Code） | 60分 |
| 配達エリア管理 | 配達エリアの登録・編集・削除、有効切替、郵便番号の正規化（PR #20） | AI（Claude Code） | 35分 |
| 日別献立管理 | 日別献立の登録・編集・削除、同日同タイプの重複チェック、残数表示、月ごとの一覧（PR #21） | AI（Claude Code） | 60分 |
| CI | bundler-audit で検出された puma の脆弱性に対応（PR #22） | AI（Claude Code） | 15分 |
| レビュー観点 | レビュー観点のチェックリストを作成し、.claude/rules/review で自動読み込みにする。FactoryBot を最小限に（PR #23） | 本人 + AI（Claude Code） | 45分 |
| レビュー | PR #18〜#23 のレビューと指摘対応（ナビの現在地、月の解釈をモデルへ移動など）、ブランチ間の衝突解消、マージ | 本人 + AI（Claude Code） | 80分 |
| 片付け | マージ済み worktree の削除、作業ログの記入 | 本人 + AI（Claude Code） | 20分 |
