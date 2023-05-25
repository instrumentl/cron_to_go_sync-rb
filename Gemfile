# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

gem "activesupport"
gem "dry-types"
gem "faraday", ">= 1.0", "< 3.0"
gem "faraday-follow_redirects"
gem "faraday-retry"
gem "interactor"
gem "interactor-contracts"
gem "toml-rb"

group :development, :test do
  gem "rspec", "~> 3.0"
  gem "rspec-its", "~>1.3"
  gem "standard", "~> 1.25.3"
  gem "pry", "~> 0.14"
  gem "webmock", "~> 3"
  gem "vcr", "~> 6"
  gem "bundle-audit", "~> 0.1.0"
end
