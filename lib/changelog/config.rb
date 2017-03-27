module Danger
  # A plugin module
  module Changelog
    # A configuration for the Danger Changelog plugin
    module Config
      extend self

      attr_accessor :placeholder_line

      def placeholder_line=(value)
        new_value = value
        new_value = "* #{new_value}" unless new_value.start_with?('* ')
        new_value = "#{new_value}\n" unless new_value.end_with?("\n")
        @placeholder_line = new_value
      end

      def reset
        self.placeholder_line = "* Your contribution here.\n"
      end

      reset
    end

    class << self
      def configure
        block_given? ? yield(Config) : Config
      end

      def config
        Config
      end
    end
  end
end
