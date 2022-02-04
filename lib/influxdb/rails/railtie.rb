require "influxdb"
require "rails"

module InfluxDB
  module Rails
    class Railtie < ::Rails::Railtie # :nodoc:
      # rubocop:disable Metrics/BlockLength
      config.after_initialize do
        InfluxDB::Rails.configure do |config|
          config.environment ||= ::Rails.env
        end

        ActiveSupport.on_load(:action_controller) do
          before_action do
            current = InfluxDB::Rails.current
            current.values = { request_id: request.request_id } if request.respond_to?(:request_id)
          end
        end

        cache = lambda do |_, _, _, _, payload|
          current = InfluxDB::Rails.current
          location = [payload[:controller], payload[:action]].join("#")
          current.tags = { location: location }
        end
        ActiveSupport::Notifications.subscribe "start_processing.action_controller", &cache

        {
          "process_action.action_controller"     => Middleware::RequestSubscriber,
          "render_template.action_view"          => Middleware::RenderSubscriber,
          "render_partial.action_view"           => Middleware::RenderSubscriber,
          "render_collection.action_view"        => Middleware::RenderSubscriber,
          "sql.active_record"                    => Middleware::SqlSubscriber,
          "instantiation.active_record"          => Middleware::ActiveRecordSubscriber,
          "enqueue.active_job"                   => Middleware::ActiveJobSubscriber,
          "perform.active_job"                   => Middleware::ActiveJobSubscriber,
          "deliver.action_mailer"                => Middleware::ActionMailerSubscriber,
          "block_instrumentation.influxdb_rails" => Middleware::BlockInstrumentationSubscriber,
        }.each do |hook_name, subscriber|
          ActiveSupport::Notifications.subscribe(hook_name, subscriber)
        end
      end
      # rubocop:enable Metrics/BlockLength
    end
  end
end
