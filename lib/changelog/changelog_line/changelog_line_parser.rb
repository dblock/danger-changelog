module Danger
  module Changelog
    # A parser of the CHANGELOG.md lines
    class ChangelogLineParser
      # Returns an instance of Changelog::ChangelogLine class based on the given line
      def self.parse(line)
        changelog_line_class = self.available_changelog_lines.find do |changelog_line|
          changelog_line.validates_as_changelog_line?(line)
        end
        return nil unless changelog_line_class
        return changelog_line_class.new(line)
      end

      private

      def self.available_changelog_lines
        [ChangelogEntryLine, ChangelogHeaderLine, ChangelogPlaceholderLine]
      end
    end
  end
end
