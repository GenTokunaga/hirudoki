RSpec.configure do |config|
  # 締切（10:00）の境界値テストで travel_to を使うため
  config.include ActiveSupport::Testing::TimeHelpers
end
