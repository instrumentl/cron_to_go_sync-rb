# frozen_string_literal: true

require_relative "lib/cron_to_go_sync/version"

Gem::Specification.new do |gem|
  gem.name = "cron_to_go_sync"
  gem.version = CronToGoSync::VERSION
  gem.authors = ["Instrumentl, Inc."]
  gem.email = ["oss@instrumentl.com"]
  gem.description = <<-EOF
    Library to synchronize a checked-in YAML file with the SaaS scheduled task service CronToGo
  EOF
  gem.summary = "CronToGo configuration syncing library"
  gem.homepage = "https://github.com/instrumentl/cron_to_go_sync-rb"
  gem.license = "ISC"
  gem.files = `git ls-files`.split($/)
  gem.require_paths = ["lib"]
  gem.metadata["homepage_uri"] = gem.homepage
  gem.metadata["source_code_uri"] = gem.homepage
  gem.metadata["changelog_uri"] = "https://github.com/instrumentl/cron_to_go_sync-rb/blob/main/CHANGELOG.md"
  gem.required_ruby_version = ">= 3.0.0"

  gem.add_dependency "activesupport"
  gem.add_dependency "dry-types"
  gem.add_dependency "dry-validation"
  gem.add_dependency "faraday", ">= 1.0", "< 3.0"
  gem.add_dependency "faraday-follow_redirects"
  gem.add_dependency "faraday-retry"
  gem.add_dependency "interactor"
  gem.add_dependency "interactor-contracts"
  gem.add_dependency "toml-rb"
end
