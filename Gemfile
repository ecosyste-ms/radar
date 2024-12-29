source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.1'

gem "rails"

gem "sprockets-rails"

gem "pg"

gem "puma"

gem "jbuilder"

gem "bootsnap", require: false


gem "sassc-rails"

gem 'faraday-typhoeus'
gem 'faraday'
gem "faraday-retry"
gem "faraday-gzip"
gem "faraday-follow_redirects"

gem 'semantic_range'

gem 'pagy'

gem 'bootstrap'
gem 'jquery-rails'
gem 'octokit'


group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem 'dotenv-rails'
end

group :development do
  gem "web-console"
end

group :test do
  gem "shoulda-matchers"
  gem "shoulda-context"
  gem "webmock"
  gem "mocha"
  gem "rails-controller-testing"
end
