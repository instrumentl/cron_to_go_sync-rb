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

    it "validates schedule range" do
      input_hash = {"job_name" => {schedule: "* * * * 1-5", enabled: true, ttl: 86400, dyno_size: "Basic", command: "/bin/true"}}
      parsed = described_class.parse_hash(input_hash)
      expect(parsed["job_name"][:schedule]).to eq "* * * * 1-5"
    end

    it "validates schedule range values" do
      input_hash = {"job_name" => {schedule: "* * * * 1-9", enabled: true, ttl: 86400, dyno_size: "Basic", command: "/bin/true"}}
      expect { described_class.parse_hash(input_hash) }.to raise_error(RuntimeError, /invalid range upper/)
    end

    it "validates schedule range order" do
      input_hash = {"job_name" => {schedule: "* * * * 5-1", enabled: true, ttl: 86400, dyno_size: "Basic", command: "/bin/true"}}
      expect { described_class.parse_hash(input_hash) }.to raise_error(RuntimeError, /range not in order/)
    end
  end
end
