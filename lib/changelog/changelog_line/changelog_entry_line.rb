require 'changelog/changelog_line/changelog_line'

module Danger
  module Changelog
    # A CHANGELOG.md line represents the change entry.
    class ChangelogEntryLine < ChangelogLine
      def valid?
        return true if line =~ %r{^\*\s[\`[:upper:]].*[^.,] \- \[\@[\w\d\-\_]+\]\(https:\/\/github\.com\/.*[\w\d\-\_]+\).$}
        return true if line =~ %r{^\*\s\[\#\d+\]\(https:\/\/github\.com\/.*\d+\)\: [\`[:upper:]].*[^.,] \- \[\@[\w\d\-\_]+\]\(https:\/\/github\.com\/.*[\w\d\-\_]+\).$}

        false
      end

      def self.validates_as_changelog_line?(line)
        matched_rules_count = 0
        matched_rules_count += 1 if starts_with_star?(line)
        matched_rules_count += 1 if with_pr_link?(line)
        matched_rules_count += 1 if with_changelog_description?(line)
        matched_rules_count += 1 if with_author_link?(line)
        matched_rules_count >= 2
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

      # checks whether line starts with *
      def self.starts_with_star?(line)
        return true if line =~ /^\*\s/

        false
      end

      # checks whether line contains a MARKDOWN  link to a PR
      def self.with_pr_link?(line)
        return true if line =~ %r{\[\#\d+\]\(http[s]?:\/\/github\.com\/.*\d+[\/]?\)}

        false
      end

      # checks whether line contains a capitalized Text, treated as a description
      def self.with_changelog_description?(line)
        return true if line =~ /[\`[:upper:]].*/

        false
      end

      # checks whether line contains a MARKDOWN  link to an author
      def self.with_author_link?(line)
        return true if line =~ %r{\[\@[\w\d\-\_]+\]\(http[s]?:\/\/github\.com\/.*[\w\d\-\_]+[\/]?\)}

        false
      end
    end
  end
end
