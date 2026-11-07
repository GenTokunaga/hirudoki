# System Spec Examples

### ファイル名に配置ディレクトリと重複するプレフィックスを付けない

```text
# NG: ディレクトリ名 settings/task_templates を接頭辞で重複
spec/system/settings/task_templates/settings_task_templates_exports_spec.rb

# OK: ディレクトリ構造で文脈が示されるため冗長な接頭辞は不要
spec/system/settings/task_templates/task_templates_exports_spec.rb
```

### describe はクラス名/名前空間でなくテスト対象機能の日本語テキスト

```ruby
# NG: クラス名・名前空間をそのまま describe にする
describe 'Settings::TaskTemplates::Exports', type: :system do
end

# OK: ユーザー視点の機能（振る舞い）を日本語で表す
describe '繰り返しタスクのJSONエクスポート', type: :system do
end
```
