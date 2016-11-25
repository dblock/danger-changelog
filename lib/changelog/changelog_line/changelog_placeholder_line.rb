module Danger
  module Changelog
    # A CHANGELOG.md line represents the "Your contribution here".
    class ChangelogPlaceholderLine < ChangelogLine
      def valid?
        true
      end

      def self.validates_as_changelog_line?(line)
        return true if line == "* Your contribution here.\n"
        false
      end
    end
  end
end
