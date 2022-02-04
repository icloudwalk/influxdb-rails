require "influxdb/rails/middleware/subscriber"

module InfluxDB
  module Rails
    module Middleware
      class ActionMailerSubscriber < Subscriber # :nodoc:
        private

        def values
          { value: 1 }
        end

        def tags
          {
            hook:   "deliver",
            mailer: payload[:mailer],
          }
        end
      end
    end
  end
end
