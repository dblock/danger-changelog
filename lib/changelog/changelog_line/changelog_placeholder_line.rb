module Danger
  module Changelog
    # A CHANGELOG.md line represents the "Your contribution here".
    class ChangelogPlaceholderLine < ChangelogLine
      def valid?
        ChangelogPlaceholderLine.validates_as_changelog_line?(line, plugin_configuration)
      end

      def self.validates_as_changelog_line?(line, plugin_configuration = Danger::Changelog::PluginConfiguration.new())
        return true if line == plugin_configuration.placeholder_line
        false
      end
    end
  end
end
