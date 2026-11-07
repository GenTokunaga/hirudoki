---
paths: ["app/**/*.rb"]
---
# Rails Rules

## Principles

- 許可リスト優先 (`skip_before_action` 等は `except` でなく `only` / アクション追加時の設定漏れ防止)
- DB 側で処理 (列値取得は `map` より `pluck` / 集計は `group`・`count` / 一覧取得は必ず `order` を付与)
- 関連は preload (`eager_load` でなく `preload` / preload 済みに `exists?`・`count` でなく `present?`・`size`)
- bang メソッドで失敗を顕在化 (`create!`/`update!`/`destroy!` / seed・スクリプトも `create!`)
- 大量データは `find_each` (メモリ枯渇防止)
- 安全なデータ取得 (オブジェクト取得はログインユーザー起点 / 権限チェック漏れは Pundit 等で検知)
- DB レベルの整合性 (NOT NULL 制約・ユニークインデックス / 複数レコード更新はトランザクションで囲む)
- コントローラは薄く (リクエスト処理とレスポンス準備に限定 / データ操作のロジックはモデルへ委譲)
- namespace で責務分離 (ユーザー種別ごとに namespace を分け権限分岐を減らす / 基底コントローラ `Admins::ApplicationController` を継承)
- RESTful ルーティング (`resources` / ユーザーから単一のリソースは単数 `resource` で id なし URL / ネストは `module` オプションで配置と対応)
- ビューはロジックを持たない (ActionView ヘルパー / Model / Decorator / ViewComponent へ移動 / コンポーネントのルート要素は 1 つ・マージンは親側)
- 日時は `I18n.l` でフォーマット (表記揺れ・国際化対応)
- 環境依存値は外部化 (`Rails.env` 分岐でなく環境変数 / `credentials.yml.enc`)
- YAGNI と単一責任 (将来予測の過剰実装を避ける / 抽象的な `check_xxx` でなく結果が分かる具体名)

## Examples

詳細な Rails レビュー観点は `doc/agent/code-review-rails.md` を参照。
