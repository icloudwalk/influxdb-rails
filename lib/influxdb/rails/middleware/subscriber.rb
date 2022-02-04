require "influxdb/rails/metric"

module InfluxDB
  module Rails
    module Middleware
      # Subscriber acts as base class for different *Subscriber classes,
      # which are intended as ActiveSupport::Notifications.subscribe
      # consumers.
      class Subscriber
        def initialize(configuration:, hook_name:, start:, finish:, payload:)
          @configuration = configuration
          @hook_name = hook_name
          @start = start
          @finish = finish
          @payload = payload
        end

        def self.call(name, start, finish, _id, payload)
          new(
            configuration: InfluxDB::Rails.configuration,
            start:         start,
            finish:        finish,
            payload:       payload,
            hook_name:     name
          ).write
        end

        def write
          return if disabled?

          metric.write
        rescue StandardError => e
          ::Rails.logger.error("[InfluxDB::Rails] Unable to write points: #{e.message}")
        end

        private

        attr_reader :configuration, :hook_name, :start, :finish, :payload

        def metric
          InfluxDB::Rails::Metric.new(
            values:        values,
            tags:          tags,
            configuration: configuration,
            timestamp:     finish
          )
        end

        def tags
          raise NotImplementedError, "must be implemented in subclass"
        end

        def values
          raise NotImplementedError, "must be implemented in subclass"
        end

        def duration
          ((finish - start) * 1000).ceil
        end

        def disabled?
          configuration.ignore_current_environment? ||
            configuration.ignored_hooks.include?(hook_name)
        end
      end
    end
  end
end
