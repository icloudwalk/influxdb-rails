require_relative "../test_client"
require "launchy"

module InfluxDB
  module Rails
    module Matchers
      def expect_metric(name: "rails", **options)
        expect(metrics).to include(
          a_hash_including(options.merge(name: name))
        )
      end

      def expect_no_metric(name: "rails", **options)
        expect(metrics).not_to include(
          a_hash_including(options.merge(name: name))
        )
      end

      def save_and_open_metrics
        dir = File.join(File.dirname(__FILE__), "..", "..", "tmp")
        FileUtils.mkdir_p(dir)
        file_path = File.join(dir, "metrics.json")
        output = JSON.pretty_generate(metrics)
        File.write(file_path, output, mode: "wb")
        ::Launchy.open(file_path)
      end

      def metrics
        TestClient.metrics
      end

      RSpec.configure do |config|
        config.before :each do
          InfluxDB::Rails.instance_variable_set :@configuration, nil
          InfluxDB::Rails.configure

          allow(InfluxDB::Rails).to receive(:client).and_return(InfluxDB::Rails::TestClient.new)
          allow_any_instance_of(InfluxDB::Rails::Configuration)
            .to receive(:ignored_environments).and_return(%w[development])

          InfluxDB::Rails::TestClient.metrics.clear
        end

        config.include InfluxDB::Rails::Matchers
      end
    end
  end
end
