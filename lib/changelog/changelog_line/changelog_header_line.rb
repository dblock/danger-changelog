module Danger
  module Changelog
    # A CHANGELOG.md line represents the version header.
    class ChangelogHeaderLine < ChangelogLine
      def valid?
        true
      end

      def self.validates_as_changelog_line?(line)
        line =~ %r{^\#+}
      end
    end
  end
end
