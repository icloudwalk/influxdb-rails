module InfluxDB
  module Rails
    module Sql
      class Normalizer # :nodoc:
        def initialize(query)
          @query = query.dup
        end

        def perform
          query.squish!
          query.gsub!(/(\s(=|>|<|>=|<=|<>|!=)\s)('[^']+'|[$+\-\w.]+)/, '\1xxx')
          query.gsub!(/(\sIN\s)\([^()]+\)/i, '\1(xxx)')
          regex = /(\sBETWEEN\s)('[^']+'|[+\-\w.]+)(\sAND\s)('[^']+'|[+\-\w.]+)/i
          query.gsub!(regex, '\1xxx\3xxx')
          query.gsub!(/(\sVALUES\s)\(.+\)/i, '\1(xxx)')
          query.gsub!(/(\s(LIKE|ILIKE|SIMILAR TO|NOT SIMILAR TO)\s)('[^']+')/i, '\1xxx')
          query.gsub!(/(\s(LIMIT|OFFSET)\s)(\d+)/i, '\1xxx')
          query
        end

        private

        attr_reader :query
      end
    end
  end
end
