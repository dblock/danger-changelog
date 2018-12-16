module Danger
  module Changelog
    # A CHANGELOG.md line represents the version header.
    class ChangelogHeaderLine < ChangelogLine
      def valid?
        return true if line.strip =~ /^\#{1,4}\s.+[^\)]$/ # no date at all
        return true if line.strip =~ /^\#{1,4}\s.+\(\w*\)$/ # next date
        return true if line.strip =~ %r{^\#{1,4}\s.+\s\(([0-9]{4})[-/]?(1[0-2]|0?[1-9])[-/]+(3[01]|0?[1-9]|[12][0-9])\)$} # iso 8601 date

        false
      end

      def self.validates_as_changelog_line?(line)
        return true if line =~ /^\#{1,4}\s.+/

        false
      end
    end
  end
end
