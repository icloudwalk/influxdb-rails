module InfluxDB
  module Rails
    class Context
      def reset
        Thread.current[:_influxdb_rails_tags] = {}
        Thread.current[:_influxdb_rails_values] = {}
      end

      def tags
        Thread.current[:_influxdb_rails_tags].to_h
      end

      def tags=(tags)
        Thread.current[:_influxdb_rails_tags] = self.tags.merge(tags)
      end

      def values
        Thread.current[:_influxdb_rails_values].to_h
      end

      def values=(values)
        Thread.current[:_influxdb_rails_values] = self.values.merge(values)
      end
    end
  end
end
