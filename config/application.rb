require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Hirudoki
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # 注文締切（提供日当日 10:00）を日本時間で判定するため
    config.time_zone = "Tokyo"

    # 画面・エラーメッセージを日本語で表示する
    config.i18n.default_locale = :ja
    config.i18n.available_locales = %i[ja en]
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
