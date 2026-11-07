---
paths: ["spec/system/**/*.rb"]
---
# System Spec Rules

## Principles

- ユーザー視点の動線確認に限定 (基本動線と操作後の画面変化を確認 / 過度な網羅性を求めず細部はユニットテストへ)
- デザイン非依存の要素指定 (CSS クラスでなく `data-test-id` 等のテスト専用属性で指定)
- レスポンス待ちは表示要素で (`sleep` を使わず `expect(page).to have_content(...)` 等で待つ)

## Examples

When in doubt: ../../rules-extras/frameworks/rspec-system.examples.md
