module InfluxDB
  module Rails
    class Tags
      def initialize(config:, tags: {}, additional_tags: InfluxDB::Rails.current.tags)
        @tags = tags
        @config = config
        @additional_tags = additional_tags
      end

      def to_h
        expanded_tags.reject do |_, value|
          value.to_s.blank?
        end
      end

      private

      attr_reader :additional_tags, :tags, :config

      def expanded_tags
        config.tags_middleware.call(tags.merge(default_tags))
      end

      def default_tags
        {
          server:   Socket.gethostname,
          app_name: config.application_name,
          location: :raw,
        }.merge(additional_tags)
      end
    end
  end
end
