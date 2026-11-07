---
paths: ["spec/system/**/*.rb"]
---
# System Spec 命名・構成（プロジェクト固有）

## Project-specific patterns

- ファイル名に配置ディレクトリと重複するプレフィックスを付けない - 例: `settings/task_templates/task_templates_exports_spec.rb`（`settings_task_templates_` を付けない）
- describe はクラス名/名前空間でなくテスト対象機能の日本語テキスト - 例: `describe '繰り返しタスクのJSONエクスポート', type: :system`
- 本方針は新規ファイルに適用 - 既存 `settings_*_spec.rb` 群や `RSpec.describe 'Settings::...'` は順次移行予定で未修正のまま。既存に合わせず本方針に従う

## Examples

When in doubt: ../../rules-extras/frameworks/rspec-system.examples.md
