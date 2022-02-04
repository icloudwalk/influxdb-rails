module InfluxDB
  module Rails
    class Values
      def initialize(values: {}, additional_values: InfluxDB::Rails.current.values)
        @values = values
        @additional_values = additional_values
      end

      def to_h
        expanded_values.reject do |_, value|
          value.to_s.blank?
        end
      end

      private

      attr_reader :additional_values, :values

      def expanded_values
        values.merge(additional_values)
      end
    end
  end
end
