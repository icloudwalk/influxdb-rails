require "influxdb/rails/middleware/subscriber"
require "influxdb/rails/sql/query"

module InfluxDB
  module Rails
    module Middleware
      class ActiveRecordSubscriber < Subscriber # :nodoc:
        private

        def values
          {
            value:        duration,
            record_count: payload[:record_count],
          }
        end

        def tags
          {
            hook:       "instantiation",
            class_name: payload[:class_name],
          }
        end
      end
    end
  end
end
