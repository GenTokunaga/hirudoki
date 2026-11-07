---
paths: ["spec/**/*.rb"]
---
# RSpec Rules

## Principles

- 日本語の説明文 (describe/context/it は機能・状況・期待値を日本語で記述 / メソッド名・クラス名などの識別子はそのまま)
- 仕様書として機能するテスト (対象コードの仕様が一目で分かる / バグを確実に検出できる)
- 価値基準による取捨選択 (「失敗したら実問題が起きるか」を自問 / フレームワーク標準機能はテストしない / private メソッドは直接テストせずパブリックインターフェース経由)
- AAA 構造 (Arrange-Act-Assert を明確に分離 / Act は it 内で実行、before には Arrange のみ)
- 期待値に DRY を適用しない (計算ロジックから導出せずベタ書き / 変数より直値で根拠を明示)
- 明確さ優先 (読みやすさ最優先 / 上から下へストレートに読める / スマートさより分かりやすさ)
- 静的な DSL 構築 (メタプロやループで let・it を動的生成しない / `create_list` を使う)
- スコープ最小化 (トップレベル describe は 1 つ / method・shared_examples は describe 内で定義 / context で整理)
- TDD 後のコメント整理 (一時コメントや古い説明を削除し意図を明確化)

## Examples

When in doubt: ../../rules-extras/frameworks/rspec.examples.md
