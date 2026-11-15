---
paths: ["spec/**/*.rb"]
---
# RSpec プロジェクト固有ルール

## Project-specific patterns

- `require 'rails_helper'` を省略 - `.rspec` に `--require spec_helper --require rails_helper` 設定済み
- `RSpec.describe` の `RSpec.` プレフィックスを省略 - `describe` で動作
- 作成・維持する spec は model spec と system spec のみ
- `spec/controllers` は禁止 - コントローラのロジックはモデルへ寄せ E2E は system spec でカバー
- `spec/views` は禁止
- `spec/routing` は禁止
- 認可（admin 権限など）のテストは system spec で実装 - before_action もそこでカバーされる
- model spec は複雑なビジネスロジック/カスタムバリデーションのみ - presence・length・format 等の単純バリデーションは書かない
- 数値の範囲（上限・下限）は model spec で境界値を確認する - 下限ちょうど・下限 - 1・上限ちょうど・上限 + 1 の 4 つ。system spec では確認しない
- `let!` の乱用回避 - 遅延評価のため本当に必要な時のみ使用
- `action_on_unpermitted_parameters` を `:raise` に設定 - Strong Parameter の設定漏れを検知

## Examples

When in doubt: ../../rules-extras/frameworks/rspec.examples.md
