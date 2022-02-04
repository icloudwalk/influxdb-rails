module InfluxDB
  module Rails
    module BrokenClient
      def setup_broken_client
        client = double
        allow(client).to receive(:write_point).and_raise("message")
        allow(InfluxDB::Rails).to receive(:client).and_return(client)
      end
    end
  end
end
