source 'https://rubygems.org'

gem 'aws-sdk-s3', require: false
gem 'bootsnap', require: false
gem 'cssbundling-rails'
gem 'devise'
gem 'devise-i18n'
gem 'haml-rails'
gem 'importmap-rails'
gem 'jbuilder'
gem 'kamal', require: false
# NOTE: Rails の PostgreSQL アダプターは pg 1.x でないと起動時にエラーになるため、bundle update で 2.x に上がらないよう固定している
gem 'pg', '~> 1.1'
gem 'propshaft'
gem 'puma'
gem 'rails', '~> 8.1.4'
gem 'rails-i18n'
gem 'simple_form'
gem 'stimulus-rails'
gem 'thruster', require: false
gem 'turbo-rails'
gem 'tzinfo-data', platforms: %i[windows jruby]

group :development, :test do
  gem 'brakeman', require: false
  gem 'bundler-audit', require: false
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'
  gem 'factory_bot_rails'
  gem 'haml-lint'
  gem 'rspec-rails'
  gem 'rubocop-rails-omakase', require: false
  gem 'sgcop', github: 'SonicGarden/sgcop'
end

group :development do
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'simplecov'
end
