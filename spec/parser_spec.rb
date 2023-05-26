require "spec_helper"

RSpec.describe CronToGoSync::Parser do
  describe "#parse_hash" do
    it "accepts a valid schedule" do
      input_hash = {"job_name" => {schedule: "* * * * *", enabled: true, ttl: 86400, dyno_size: "Basic", command: "/bin/true"}}
      expect(described_class.parse_hash(input_hash)).to eq({
        "job_name" => {
          alias: "job_name",
          schedule: "* * * * *",
          enabled: true,
          ttl: 86400,
          dyno_size: "Basic",
          command: "/bin/true"
        }
      })
    end

    it "validates number of fields" do
      input_hash = {"job_name" => {schedule: "* * * *", enabled: true, ttl: 86400, dyno_size: "Basic", command: "/bin/true"}}
      expect { described_class.parse_hash(input_hash) }.to raise_error(RuntimeError, /must contain exactly five fields/)
    end

    it "validates schedule numerator" do
      input_hash = {"job_name" => {schedule: "* 25 * * *", enabled: true, ttl: 86400, dyno_size: "Basic", command: "/bin/true"}}
      expect { described_class.parse_hash(input_hash) }.to raise_error(RuntimeError, /invalid range value/)
    end

    it "validates schedule denominator" do
      input_hash = {"job_name" => {schedule: "*/99 * * * *", enabled: true, ttl: 86400, dyno_size: "Basic", command: "/bin/true"}}
      expect { described_class.parse_hash(input_hash) }.to raise_error(RuntimeError, /invalid denominator value/)
    end
  end
end
