require 'changelog/changelog_line/changelog_line'

module Danger
  module Changelog
    # A CHANGELOG.md line represents the change entry.
    class ChangelogEntryLine < ChangelogLine
      def valid?
        return true if line =~ %r{^\*\s[\`[:upper:]].* \- \[\@[\w\d\-\_]+\]\(https:\/\/github\.com\/.*[\w\d\-\_]+\).$}
        return true if line =~ %r{^\*\s\[\#\d+\]\(https:\/\/github\.com\/.*\d+\)\: [\`[:upper:]].* \- \[\@[\w\d\-\_]+\]\(https:\/\/github\.com\/.*[\w\d\-\_]+\).$}
        false
      end

      def self.validates_as_changelog_line?(line)
        line =~ %r{[\`[:upper:]].* \- \[\@[\w\d\-\_]+\]\(https:\/\/github\.com\/.*[\w\d\-\_]+\).$}
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