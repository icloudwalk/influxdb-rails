require "influxdb/rails/middleware/subscriber"

module InfluxDB
  module Rails
    module Middleware
      class ActiveJobSubscriber < Subscriber # :nodoc:
        private

        JOB_STATE = {
          "enqueue"       => "queued",
          "perform_start" => "running",
          "perform"       => "succeeded",
        }.freeze
        private_constant :JOB_STATE

        def values
          {
            value: value,
          }
        end

        def tags
          {
            hook:  short_hook_name,
            state: job_state,
            job:   job.class.name,
            queue: job.queue_name,
          }
        end

        def job_state
          return "failed" if failed?

          JOB_STATE[short_hook_name]
        end

        def measure_performance?
          short_hook_name == "perform"
        end

        def short_hook_name
          @short_hook_name ||= fetch_short_hook_name
        end

        def fetch_short_hook_name
          return "enqueue" if hook_name.include?("enqueue")

          "perform"
        end

        def job
          @job ||= payload[:job]
        end

        def value
          return duration if measure_performance?

          1
        end

        def failed?
          payload[:aborted]
        end
      end
    end
  end
end
