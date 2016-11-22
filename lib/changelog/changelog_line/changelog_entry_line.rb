module Danger
  module Changelog
    # A CHANGELOG.md line represents the change entry.
    class ChangelogEntryLine < ChangelogLine
      CHANGELOG_ENTRY_TRAILING_REGEX = "[\`[:upper:]].* \- \[\@[\w\d\-\_]+\]\(https:\/\/github\.com\/.*[\w\d\-\_]+\).$"
      CHANGELOG_ENTRY_LEADING_REGEX = "^\*\s"

      def valid?
        return true if line =~ %r{#{CHANGELOG_ENTRY_TRAILING_REGEX}#{CHANGELOG_ENTRY_TRAILING_REGEX}}
        return true if line =~ %r{#{CHANGELOG_ENTRY_TRAILING_REGEX}\[\#\d+\]\(https:\/\/github\.com\/.*\d+\)\: #{CHANGELOG_ENTRY_TRAILING_REGEX}}
        false
      end

      def self.validates_as_changelog_line?(line)
        line =~ %r{#{CHANGELOG_ENTRY_TRAILING_REGEX}}
      end
    end
  end
end
