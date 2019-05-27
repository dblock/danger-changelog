require 'changelog/parsers/base'
require 'changelog/parsers/intridea_format'

module Danger
  module Changelog
    module Parsers
      def self.default_format
        :intridea
      end

      def self.lookup(format)
        { intridea: IntrideaFormat }
          .fetch(format, IntrideaFormat)
          .new
      end
    end
  end
end
