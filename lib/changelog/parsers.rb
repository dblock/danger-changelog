# frozen_string_literal: true

require 'changelog/parsers/base'
require 'changelog/parsers/intridea_format'
require 'changelog/parsers/keep_a_changelog'

module Danger
  module Changelog
    module Parsers
      def self.default_format
        :intridea
      end

      def self.lookup(format)
        { intridea: IntrideaFormat, keep_a_changelog: KeepAChangelog }
          .fetch(format, IntrideaFormat)
          .new
      end
    end
  end
end
