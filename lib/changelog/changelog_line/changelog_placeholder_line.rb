module Danger
  module Changelog
    # A CHANGELOG.md line represents the "Your contribution here".
    class ChangelogPlaceholderLine < ChangelogLine
      def valid?
        ChangelogPlaceholderLine.validates_as_changelog_line?(line, config: config)
      end

      def self.validates_as_changelog_line?(line, config: Danger::Changelog.config)
        return true if line == config.placeholder_line

        false
      end
    end
  end
end
