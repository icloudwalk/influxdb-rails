require "#{File.dirname(__FILE__)}/../spec_helper"

RSpec.describe "Context", type: :request do
  it "resets the context after a request" do
    get "/metrics"

    expect_metric(
      tags: a_hash_including(
        location: "MetricsController#index",
        hook:     "sql"
      )
    )

    expect(InfluxDB::Rails.current.tags).to be_empty
    expect(InfluxDB::Rails.current.values).to be_empty
  end

  it "resets the context after a request when exceptioni occurs" do
    setup_broken_client

    get "/metrics"

    expect_no_metric(hook: "process_action")
    expect(InfluxDB::Rails.current.tags).to be_empty
    expect(InfluxDB::Rails.current.values).to be_empty
  end
end
