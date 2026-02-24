source "https://rubygems.org"

ruby "~> 3.2"

# Rails 7.x
gem "rails", "~> 7.1"

# PostgreSQL adapter
gem "pg", "~> 1.5"

# Web server
gem "puma", "~> 6.0"

# Asset pipeline
gem "sprockets-rails"

# Hotwire (Turbo + Stimulus)
gem "turbo-rails"
gem "stimulus-rails"

# Build JSON APIs
gem "jbuilder"

# Reduces boot times through caching
gem "bootsnap", require: false

# Windows timezone data
gem "tzinfo-data", platforms: %i[windows jruby]

group :development, :test do
  gem "debug", platforms: %i[mri windows]
end

group :development do
  gem "web-console"
  gem "foreman"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end

