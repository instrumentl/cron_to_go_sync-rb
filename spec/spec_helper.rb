require "rspec"
require "rspec/its"
require "webmock/rspec"
require "vcr"

require "cron_to_go_sync"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  WebMock.disable_net_connect!(
    allow_localhost: true
  )
end

class JsonNlSerializer
  class << self
    def file_extension
      "json"
    end

    def serialize(hash)
      JSON.dump(hash) + "\n"
    end

    def deserialize(s)
      JSON.parse(s)
    end
  end
end

VCR.configure do |config|
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :webmock
  config.ignore_localhost = true
  config.ignore_hosts "localhost", "127.0.0.1"
  config.cassette_serializers[:jsonnl] = JsonNlSerializer
  config.default_cassette_options = {
    serialize_with: :jsonnl,
    record: (ENV["CI"] == "true") ? :none : :once
  }
  config.configure_rspec_metadata!
  ["CRONTOGO_API_KEY", "CRONTOGO_ORGANIZATION_ID"].each do |sensitive_env_var|
    config.filter_sensitive_data("<#{sensitive_env_var.downcase}>") { ENV[sensitive_env_var] }
  end
  config.filter_sensitive_data("<basic auth header>") do |interaction|
    interaction.request.headers["Authorization"]&.first&.sub("Basic ", "")
  end
end
