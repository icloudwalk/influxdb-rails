require "spec_helper"

RSpec.describe InfluxDB::Rails do
  describe ".instrument" do
    it "supports calling wihout a block" do
      InfluxDB::Rails.instrument "name", values: { value: 1 }

      expect_metric(
        values: a_hash_including(value: 1),
        tags:   a_hash_including(
          hook:     "block_instrumentation",
          server:   Socket.gethostname,
          location: :raw
        )
      )
    end
  end
end
