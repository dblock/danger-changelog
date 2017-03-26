require 'changelog/changelog_line/changelog_entry_line'
require 'changelog/changelog_line/changelog_header_line'
require 'changelog/changelog_line/changelog_placeholder_line'

module Danger
  module Changelog
    # A parser of the CHANGELOG.md lines
    class ChangelogLineParser
      # Returns an instance of Changelog::ChangelogLine class based on the given line
      def self.parse(line, plugin_configuration = Danger::Changelog::PluginConfiguration.new())
        changelog_line_class = available_changelog_lines.find do |changelog_line|
          changelog_line.validates_as_changelog_line?(line, plugin_configuration)
        end
        return nil unless changelog_line_class
        changelog_line_class.new(line, plugin_configuration)
      end

      private_class_method

      def self.available_changelog_lines
        # Order is important
        [ChangelogPlaceholderLine, ChangelogEntryLine, ChangelogHeaderLine]
      end
    end
  end
end
