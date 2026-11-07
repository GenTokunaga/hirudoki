# プロジェクト固有ルール（hirudoki）

「ひるどき」は、日替わりの弁当を注文すると自宅やオフィスまで届けてくれる宅配サイトです。 利用者はその日の献立を見て注文し、管理者は献立・注文・配達を管理します。

## ビュー

- ビューファイルは ERB ではなく Haml で書く（`*.html.haml`）
  - 例外：HTML 以外のテンプレート（メールのテキスト版 `*.text.erb`、`*.json.erb` など）は ERB のままでよい
  - 書いたら `bundle exec haml-lint` で指摘がないことを確認する

## 国際化（i18n）

- 日時表示は `I18n.l` を使用

## レビュー観点の参照

- 一般: `doc/agent/code-review.md` / Rails: `doc/agent/code-review-rails.md`
- 金額計算が絡む場合: `doc/agent/code-review-money.md` / クレジットカード決済: `doc/agent/code-review-credit.md`
- RSpec: `doc/agent/spec.md`
