module Danger
  module Changelog
    # A CHANGELOG.md line represents the version header.
    class ChangelogHeaderLine < ChangelogLine
      def valid?
        ChangelogHeaderLine.validates_as_changelog_line?(line, plugin_configuration)
      end

      def self.validates_as_changelog_line?(line, _plugin_configuration = Danger::Changelog::PluginConfiguration.default)
        return true if line =~ /^\#{1,4}\s.+/
        false
      end
    end
  end
end
