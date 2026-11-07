---
paths: ["app/**/*.rb"]
---
# Rails プロジェクト固有ルール

## Project-specific patterns

- `enumerize :role, in: %i[normal admin], predicates: { prefix: true }` - User のロールは enumerize gem（enum でない）。`alias admin? role_admin?` あり
- Decorator は Decoru gem - `app/decorators/`（例: `task_decorator.rb`）
- ViewComponent は `app/components/` 配置
- 共有モデル動作は `app/models/concerns/`（Taskable, GithubGraphqlClientable）/ 共有コントローラ動作は `app/controllers/concerns/`（TaskSortable）
- namespace 配下の基底コントローラを継承 - `admins/` `auth/` `my/` `settings/` 等
