require "#{File.dirname(__FILE__)}/../spec_helper"

RSpec.describe "ActiveRecord SQL metrics", type: :request do
  let(:tags_middleware) do
    lambda do |tags|
      tags.merge(tags_middleware: :tags_middleware)
    end
  end
  before do
    allow_any_instance_of(ActionDispatch::Request).to receive(:request_id).and_return(:request_id)
    allow_any_instance_of(InfluxDB::Rails::Configuration).to receive(:application_name).and_return(:app_name)
    allow_any_instance_of(InfluxDB::Rails::Configuration).to receive(:tags_middleware).and_return(tags_middleware)
  end

  it "writes metric" do
    skip("https://github.com/rails/rails/issues/30586") unless payload_names_fixed_in_rails?

    get "/metrics"

    expect_metric(
      tags:   a_hash_including(
        hook:       "sql",
        name:       "Metric Create",
        class_name: "Metric",
        operation:  "INSERT"
      ),
      values: a_hash_including(
        value: be_between(1, 500),
        sql:   "INSERT INTO \"metrics\" (\"name\", \"created_at\", \"updated_at\") VALUES (xxx)"
      )
    )
  end

  it "writes metric" do
    skip("https://github.com/rails/rails/issues/30586") if payload_names_fixed_in_rails?

    get "/metrics"

    expect_metric(
      tags:   a_hash_including(
        hook:       "sql",
        name:       "SQL",
        class_name: "SQL",
        operation:  "INSERT"
      ),
      values: a_hash_including(
        value: be_between(1, 500),
        sql:   "INSERT INTO \"metrics\" (\"name\", \"created_at\", \"updated_at\") VALUES (xxx)"
      )
    )
  end

  it "includes correct timestamps" do
    travel_to Time.zone.local(2018, 1, 1, 9, 0, 0)

    get "/metrics"

    expect_metric(
      tags:      a_hash_including(
        hook:     "sql"
      ),
      timestamp: 1_514_797_200
    )
  end

  it "does not write metric when hook is ignored" do
    allow_any_instance_of(InfluxDB::Rails::Configuration).to receive(:ignored_hooks).and_return(["sql.active_record"])

    get "/metrics"

    expect_no_metric(
      tags: a_hash_including(
        hook:     "sql"
      )
    )
  end

  def payload_names_fixed_in_rails?
    Rails::VERSION::MAJOR > 5 ||
      rails_after_5_1?
  end

  def rails_after_5_1?
    Rails::VERSION::MAJOR == 5 &&
      Rails::VERSION::MINOR > 1
  end
end
