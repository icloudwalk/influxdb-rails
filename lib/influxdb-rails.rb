require "net/http"
require "net/https"
require "rubygems"
require "socket"
require "influxdb/rails/middleware/block_instrumentation_subscriber"
require "influxdb/rails/middleware/render_subscriber"
require "influxdb/rails/middleware/request_subscriber"
require "influxdb/rails/middleware/sql_subscriber"
require "influxdb/rails/middleware/active_record_subscriber"
require "influxdb/rails/middleware/active_job_subscriber"
require "influxdb/rails/middleware/action_mailer_subscriber"
require "influxdb/rails/sql/query"
require "influxdb/rails/version"
require "influxdb/rails/configuration"
require "influxdb/rails/context"

require "influxdb/rails/railtie" if defined?(Rails::Railtie)

module InfluxDB
  # InfluxDB::Rails contains the glue code needed to integrate with
  # InfluxDB and Rails. This is a singleton class.
  module Rails
    class << self
      attr_writer :configuration, :client

      def configure
        return configuration unless block_given?

        yield configuration
        self.client = nil # if we change configuration, reload the client
      end

      # rubocop:disable Metrics/MethodLength

      def client
        @client ||= begin
          cfg = configuration.client
          InfluxDB::Client.new \
            database:       cfg.database,
            username:       cfg.username,
            password:       cfg.password,
            auth_method:    cfg.auth_method,
            hosts:          cfg.hosts,
            port:           cfg.port,
            async:          cfg.async,
            use_ssl:        cfg.use_ssl,
            retry:          cfg.retry,
            open_timeout:   cfg.open_timeout,
            read_timeout:   cfg.read_timeout,
            max_delay:      cfg.max_delay,
            time_precision: cfg.time_precision,
            prefix:	     cfg.prefix,
            auth_method:    cfg.auth_method
        end
      end

      # rubocop:enable Metrics/MethodLength

      def configuration
        @configuration ||= InfluxDB::Rails::Configuration.new
      end

      def current
        @current ||= InfluxDB::Rails::Context.new
      end

      def instrument(name, options = {})
        ActiveSupport::Notifications.instrument "block_instrumentation.influxdb_rails",
                                                **options.merge(name: name) do
          yield if block_given?
        end
      end
    end
  end
end
