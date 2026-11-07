module DbConstraintHelpers
  # モデルのバリデーションを通さずに保存し、DB の制約で弾かれることを確かめる。
  # バリデーションの漏れがあっても、DB でデータの整合性が守られることを確認するため。
  def expect_db_to_reject(record, error_class = ActiveRecord::StatementInvalid)
    expect { record.save!(validate: false) }.to raise_error(error_class)
  end
end

RSpec.configure do |config|
  config.include DbConstraintHelpers, type: :model
end
