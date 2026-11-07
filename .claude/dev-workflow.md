---
reviewer: "ask-peer"
review_iterations: 3
language: "ja"
check_commands:
  - "bundle exec rubocop"
  - "bundle exec haml-lint"
---

# Dev Workflow 設定

`/dev-workflow --init` により生成。check_commands は Ruby の静的解析（rubocop（sgcop 設定を継承）/ haml-lint）
