module DbConstraintHelpers
  # NOTE: バリデーションの漏れや update_column などでバリデーションを通らなくても、DB で整合性が守られることを確かめるため
  def expect_db_to_reject(record, error_class = ActiveRecord::StatementInvalid)
    expect { record.save!(validate: false) }.to raise_error(error_class)
  end
end

RSpec.configure do |config|
  config.include DbConstraintHelpers, type: :model
end
