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

      # provide an example of a CHANGELOG line based on a commit message
      def self.example(github)
        pr_number = github.pr_json['number']
        pr_url = github.pr_json['html_url']
        pr_title = github.pr_title
                         .sub(/[?.!,;]?$/, '')
                         .capitalize
        pr_author = github.pr_author
        pr_author_url = "https://github.com/#{github.pr_author}"
        "* [##{pr_number}](#{pr_url}): #{pr_title} - [@#{pr_author}](#{pr_author_url})."
      end
    end
  end
end
