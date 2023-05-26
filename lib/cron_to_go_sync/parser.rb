require "dry-types"
require "dry-validation"
require "toml-rb"

module CronToGoSync
  module Parser
    module Types
      include Dry::Types()

      State = Types::String.enum("enabled", "paused")
      DynoSize = Types::String.enum("Eco", "Basic", "Standard-1X", "Standard-2X", "Performance-M", "Performance-L")
    end

    class JobContract < Dry::Validation::Contract
      params do
        required(:alias).filled(:string)
        required(:enabled).filled(:bool)
        required(:schedule).filled(:string)
        required(:ttl).value(:integer)
        required(:dyno_size).value(Types::DynoSize)
        required(:command).filled(:string)
      end

      rule(:schedule) do
        fields = value.split(" ")
        unless fields.size == 5
          key.failure("must contain exactly five fields")
          next
        end
        unless (error = valid_cron_field(fields[0], 0, 59)).nil?
          key.failure("in minute: #{error}")
        end
        unless (error = valid_cron_field(fields[1], 0, 23)).nil?
          key.failure("in hour: #{error}")
        end
        unless (error = valid_cron_field(fields[2], 1, 31)).nil?
          key.failure("in day of month: #{error}")
        end
        unless (error = valid_cron_field(fields[3], 1, 12)).nil?
          key.failure("in month: #{error}")
        end
        unless (error = valid_cron_field(fields[4], 0, 7)).nil?
          key.failure("in day of week: #{error}")
        end
      end

      private

      def valid_cron_field(value, lower_limit, upper_limit)
        parts = value.split("/")
        if parts.size == 1
          numerator = parts[0]
        elsif parts.size == 2
          numerator, denominator = parts
          return "invalid denominator" unless denominator.match?(/\A[0-9]+\z/)
          denominator = denominator.to_i
          return "invalid denominator value" if denominator < lower_limit || denominator > upper_limit
        else
          return "too many characters"
        end

        return if numerator == "*"

        # the numerator is a comma-separated list of ranges
        numerator.split(",").each do |range|
          if range.count("-") == 1
            lower, upper = range.split("-")
            lower = lower.to_i
            upper = upper.to_i
            return "invalid range lower #{lower}" if lower < lower_limit || lower > upper_limit
            return "invalid range upper #{upper}" if upper < upper_limit || upper > upper_limit
          elsif !range.match?(/\A[0-9]+\z/)
            return "invalid range value #{range}"
          else
            value = range.to_i
            return "invalid range value #{value}" if value < lower_limit || value > upper_limit
          end
        end
        nil
      end
    end

    # Parse a hash of {alias => properties}
    def self.parse_hash(hash)
      contract = JobContract.new
      hash.map do |key, value|
        res = contract.call(
          alias: key, schedule: value[:schedule], dyno_size: value[:dyno_size],
          command: value[:command], ttl: value[:ttl], enabled: value.fetch(:enabled, true)
        )
        if res.errors.present?
          raise "Invalid schedule for #{key}: #{res.errors.to_h}"
        end
        [key, res.to_h]
      end.to_h
    end

    def self.parse_toml_file(path)
      hash = TomlRB.load_file(path).with_indifferent_access
      defaults = hash.delete("DEFAULTS")
      parse_hash(hash.transform_values { defaults.merge(_1) })
    end
  end
end
