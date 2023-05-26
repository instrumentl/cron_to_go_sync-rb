require "spec_helper"

RSpec.describe CronToGoSync::SyncInteractor, :vcr, type: :interactor do
  describe "#call" do
    let(:api_key) { ENV["CRONTOGO_API_KEY"] }
    let(:organization_id) { ENV["CRONTOGO_ORGANIZATION_ID"] }
    let(:data_file) { "spec/data/staging.toml".to_s }

    subject(:context) { described_class.call(input_filename: data_file, api_key: api_key, organization_id: organization_id) }

    it "works" do
      expect(context).to be_a_success
      expect(context.created).to eq 1
      expect(context.updated).to eq 1
      expect(context.deleted).to eq 1
    end
  end
end
