require "influxdb/rails/middleware/subscriber"
require "influxdb/rails/sql/query"

module InfluxDB
  module Rails
    module Middleware
      class SqlSubscriber < Subscriber # :nodoc:
        private

        def values
          {
            value: duration,
            sql:   InfluxDB::Rails::Sql::Normalizer.new(payload[:sql]).perform,
          }
        end

        def tags
          {
            hook:       "sql",
            operation:  query.operation,
            class_name: query.class_name,
            name:       query.name,
            location:   :raw,
          }
        end

        def disabled?
          super || !query.track?
        end

        def query
          @query ||= InfluxDB::Rails::Sql::Query.new(payload)
        end
      end
    end
  end
end
