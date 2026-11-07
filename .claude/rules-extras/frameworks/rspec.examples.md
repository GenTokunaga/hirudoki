# RSpec Examples

### 静的な DSL 構築

```ruby
# NG: 動的にテストケースを生成
[1, 5, 10].each do |count|
  it "#{count}個のアイテムを処理できること" do
    items = create_list(:item, count)
    expect(service.process(items)).to be_successful
  end
end

# OK: 代表的なケースを明示的に記述
it "1個のアイテムを処理できること" do
  item = create(:item)
  expect(service.process([item])).to be_successful
end

it "複数のアイテムを処理できること" do
  items = create_list(:item, 5)
  expect(service.process(items)).to be_successful
end
```

### AAA 構造

```ruby
# NG: before ブロックに Act ステップを含める
describe '#cancel' do
  before { reservation.cancel! }

  it 'キャンセル料が発生すること' do
    expect(user.billings.count).to eq 1
  end
end

# OK: Arrange-Act-Assert を明確に分離し、期待値はベタ書き
describe '#cancel' do
  it 'キャンセルするとキャンセル料が発生すること' do
    # Act
    reservation.cancel!

    # Assert
    expect(user.billings.count).to eq 1
    billing = user.billings.first
    expect(billing.amount).to eq 500
  end
end
```

### 日本語の説明文

```ruby
# OK: 識別子はそのまま、説明文は日本語で具体的に
describe "User#name" do
  context "ユーザーが有効な場合" do
    it "名前を文字列で返すこと" do
      # ...
    end
  end
end
```
