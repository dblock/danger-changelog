module Danger
  module Changelog
    # A plugin configuration.
    class PluginConfiguration
      # The changelog file name, defaults to `CHANGELOG.md`.
      # @return   [String]
      attr_reader :placeholder_line

      def initialize(options = nil)
        setup_placeholder_line(options.nil? ? nil : options[:placeholder_line])
      end

      def self.default
        PluginConfiguration.new
      end

      private

      def setup_placeholder_line(given_placeholder_line)
        unless given_placeholder_line
          @placeholder_line = "* Your contribution here.\n"
          return
        end

        custom_placeholder_line = given_placeholder_line
        custom_placeholder_line = "* #{custom_placeholder_line}" unless custom_placeholder_line.start_with?('* ')
        custom_placeholder_line = "#{custom_placeholder_line}\n" unless custom_placeholder_line.end_with?("\n")
        @placeholder_line = custom_placeholder_line
      end
    end
  end
end
