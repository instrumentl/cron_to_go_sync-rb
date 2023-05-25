# frozen_string_literal: true

require_relative "lib/cron_to_go_sync/version"

Gem::Specification.new do |gem|
  gem.name = "cron_to_go_sync"
  gem.version = CronToGoSync::VERSION
  gem.authors = ["James Brown"]
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
end
