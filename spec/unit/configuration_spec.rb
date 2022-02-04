require "spec_helper"

RSpec.describe InfluxDB::Rails::Configuration do
  before do
    @configuration = InfluxDB::Rails::Configuration.new
  end

  describe "client configuration" do
    subject { InfluxDB::Rails.configuration.client }

    describe "#retry" do
      it "defaults to nil" do
        expect(subject.retry).to be_nil
      end

      it "can be updated" do
        InfluxDB::Rails.configure do |config|
          config.client.retry = 5
        end
        expect(subject.retry).to eql(5)
      end
    end

    describe "#open_timeout" do
      it "defaults to 5" do
        expect(subject.open_timeout).to eql(5)
      end

      it "can be updated" do
        InfluxDB::Rails.configure do |config|
          config.client.open_timeout = 5
        end
        expect(subject.open_timeout).to eql(5)
      end
    end

    describe "#read_timeout" do
      it "defaults to 300" do
        expect(subject.read_timeout).to eql(300)
      end

      it "can be updated" do
        InfluxDB::Rails.configure do |config|
          config.client.read_timeout = 5
        end
        expect(subject.read_timeout).to eql(5)
      end
    end

    describe "#max_delay" do
      it "defaults to 30" do
        expect(subject.max_delay).to eql(30)
      end

      it "can be updated" do
        InfluxDB::Rails.configure do |config|
          config.client.max_delay = 5
        end
        expect(subject.max_delay).to eql(5)
      end
    end

    describe "#time_precision" do
      it "defaults to seconds" do
        expect(subject.time_precision).to eql("s")
      end

      it "can be updated" do
        InfluxDB::Rails.configure do |config|
          config.client.time_precision = "ms"
        end
        expect(subject.time_precision).to eql("ms")
      end
    end
  end

  describe "#rails_app_name" do
    it "defaults to nil" do
      expect(InfluxDB::Rails.configuration.rails_app_name).to be(nil)
    end

    it "can be set to own name" do
      InfluxDB::Rails.configure do |config|
        config.rails_app_name = "my-app"
      end

      expect(InfluxDB::Rails.configuration.rails_app_name).to eq("my-app")
    end
  end

  describe "#tags_middleware" do
    let(:middleware) { InfluxDB::Rails.configuration.tags_middleware }
    let(:tags_example) { { a: 1, b: 2 } }

    it "by default returns unmodified tags" do
      expect(middleware.call(tags_example)).to eq tags_example
    end

    it "can be updated" do
      InfluxDB::Rails.configure do |config|
        config.tags_middleware = ->(tags) { tags.merge(c: 3) }
      end

      expect(middleware.call(tags_example)).to eq(tags_example.merge(c: 3))
    end
  end
end
