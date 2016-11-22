module Danger
  module Changelog
    # A CHANGELOG.md line represents the "Your contribution here".
    class ChangelogPlaceholderLine < ChangelogLine
      def valid?
        true
      end

      def self.validates_as_changelog_line?(line)
        line == "* Your contribution here.\n"
      end
    end
  end
end
