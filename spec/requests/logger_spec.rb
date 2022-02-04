require "#{File.dirname(__FILE__)}/../spec_helper"

RSpec.describe "Logger", type: :request do
  it "logs exception" do
    setup_broken_client
    expect(Rails.logger).to receive(:error).with(/message/).at_least(:once)

    get "/metrics"
  end
end
