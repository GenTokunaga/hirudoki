source 'https://rubygems.org'

gem 'aws-sdk-s3', require: false
gem 'bootsnap', require: false
gem 'cssbundling-rails'
gem 'haml-rails'
gem 'importmap-rails'
gem 'jbuilder'
gem 'kamal', require: false
# NOTE: Rails 8.1 が対応する 1.x 系に固定
gem 'pg', '~> 1.1'
gem 'propshaft'
# NOTE: Rails 8.1 が前提とする 5.0 以上
gem 'puma', '>= 5.0'
gem 'rails', '~> 8.1.4'
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
