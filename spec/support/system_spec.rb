RSpec.configure do |config|
  # JavaScript を使わない system spec は高速な rack_test で動かす
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  # js: true を付けた system spec だけヘッドレス Chrome で動かす
  config.before(:each, :js, type: :system) do
    driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
  end
end
