RSpec.configure do |config|
  # system spec でログイン済みの状態を作る（sign_in user）
  config.include Devise::Test::IntegrationHelpers, type: :system
  config.include Devise::Test::IntegrationHelpers, type: :request
end
