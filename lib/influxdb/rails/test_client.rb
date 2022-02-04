module InfluxDB
  module Rails
    class TestClient
      cattr_accessor :metrics do
        []
      end

      def write_point(name, options = {})
        metrics << options.merge(name: name)
      end
    end
  end
end
