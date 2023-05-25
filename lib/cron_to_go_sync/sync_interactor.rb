require "faraday"
require "faraday/follow_redirects"
require "faraday/retry"
require "interactor"
require "interactor-contracts"

module CronToGoSync
  class SyncInteractor
    include ::Interactor
    include ::Interactor::Contracts

    BASE_URL = "https://api.crontogo.com".freeze

    expects do
      required(:api_key).value(:string)
      required(:organization_id).value(:string)
      required(:input_filename).value(:string)
      optional(:timeout).value(:float)
      optional(:retries).value(:integer)
    end

    before :set_variables

    def call
      unless File.exist? context.input_filename
        context.fail!(error: "No such file found", filename: context.input_filename)
      end
      target_jobs = Parser.parse_toml_file(context.input_filename)
      existing_jobs = get_jobs_from_crontogo
      context.deleted = (existing_jobs.keys.to_set - target_jobs.keys.to_set).map do |alias_to_remove|
        delete_job existing_jobs[alias_to_remove][:id]
      end.size
      context.created = (target_jobs.keys.to_set - existing_jobs.keys.to_set).map do |alias_to_add|
        create_job target_jobs[alias_to_add]
      end.size
      context.updated = (target_jobs.keys.to_set & existing_jobs.keys.to_set).sum do |alias_to_update|
        existing = existing_jobs[alias_to_update]
        target = target_jobs[alias_to_update]
        if target.merge({id: existing[:id]}) != existing
          update_job(target, existing[:id])
          1
        else
          0
        end
      end
    end

    private

    def get_jobs_from_crontogo
      client.get(organization_url("/jobs")).body.map do |job|
        [job["Alias"], {
          alias: job["Alias"],
          schedule: job["ScheduleExpression"],
          dyno_size: job["Target"]["Size"],
          command: job["Target"]["Command"],
          ttl: job["Target"]["TimeToLive"],
          enabled: job["State"] == "enabled",
          id: job["Id"]
        }]
      end.to_h
    end

    def delete_job(id)
      client.delete(organization_url("/jobs/#{id}"))
    end

    def request_for(struct)
      {
        "Alias" => struct[:alias],
        "ScheduleExpression" => struct[:schedule],
        "ScheduleType" => "cron",
        "Target" => {
          "Type" => "dyno",
          "Size" => struct[:dyno_size],
          "Command" => struct[:command],
          "TimeToLive" => struct[:ttl]
        },
        "State" => struct[:enabled] ? "enabled" : "paused"
      }
    end

    def create_job(struct)
      client.post(organization_url("/jobs"), request_for(struct))
    end

    def update_job(struct, id)
      client.patch(organization_url("/jobs/#{id}"), request_for(struct))
    end

    def set_variables
      context.timeout ||= 10.0
      context.retries ||= 3
    end

    def api_key
      context.api_key
    end

    def organization_id
      context.organization_id
    end

    def url(path)
      "#{BASE_URL}#{path}"
    end

    def organization_url(path)
      url "/organizations/#{organization_id}#{path}"
    end

    def client
      @client ||= Faraday.new do |builder|
        builder.headers["Authorization"] = "Bearer #{api_key}"
        builder.options.timeout = context.timeout
        builder.options.open_timeout = context.timeout
        builder.request :json
        builder.response :json
        builder.response :follow_redirects
        builder.response :raise_error
        if context.retries > 0
          builder.request :retry, {max: context.retries}
        end
      end
    end
  end
end
