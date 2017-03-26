module Danger
  module Changelog
    # An abstract CHANGELOG.md line.
    class ChangelogLine
      attr_accessor :line, :plugin_configuration

      def initialize(line, plugin_configuration = Danger::Changelog::PluginConfiguration.default)
        self.line = line
        self.plugin_configuration = plugin_configuration
      end

      # Match the line with the validation rules
      def valid?
        raise 'ChangelogLine subclass must implement the valid? method'
      end

      # Match the line with the validation rules opposite to valid?
      def invalid?
        !valid?
      end

      # Match the given line if it potentially represents the specific changelog line
      def self.validates_as_changelog_line?(line, plugin_configuration = Danger::Changelog::PluginConfiguration.default)
        abort "You need to include a function for #{self} for validates_as_changelog_line?"
      end
    end
  end
end
