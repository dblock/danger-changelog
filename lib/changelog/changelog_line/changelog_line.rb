module Danger
  module Changelog
    # An abstract CHANGELOG.md line.
    class ChangelogLine
      attr_accessor :line

      def initialize(line)
        self.line = line
      end

      def valid?
        raise "ChangelogLine subclass must implement the valid? method"
      end

      def self.validates_as_changelog_line?(line)
        abort "You need to include a function for #{self} for validates_as_changelog_line?"
      end
    end
    # # A CHANGELOG.md file reader.
    # module ChangelogLine
    #   # match the PR format, with or without PR number
    #   def self.valid?(line)
    #     return true if line =~ %r{^\*\s[\`[:upper:]].* \- \[\@[\w\d\-\_]+\]\(https:\/\/github\.com\/.*[\w\d\-\_]+\)\.$}
    #     return true if line =~ %r{^\*\s\[\#\d+\]\(https:\/\/github\.com\/.*\d+\)\: [\`[:upper:]].* \- \[\@[\w\d\-\_]+\]\(https:\/\/github\.com\/.*[\w\d\-\_]+\)\.$}
    #     false
    #   end
    #
    #   def self.changelog_line?(line)
    #     return true if line =~ %r{[\`[:upper:]].* \- \[\@[\w\d\-\_]+\]\(https:\/\/github\.com\/.*[\w\d\-\_]+\)}
    #     false
    #   end
    #
    #   # provide an example of a CHANGELOG line based on a commit message
    #   def self.example(github)
    #     pr_number = github.pr_json['number']
    #     pr_url = github.pr_json['html_url']
    #     pr_title = github.pr_title
    #                      .sub(/[?.!,;]?$/, '')
    #                      .capitalize
    #     pr_author = github.pr_author
    #     pr_author_url = "https://github.com/#{github.pr_author}"
    #     "* [##{pr_number}](#{pr_url}): #{pr_title} - [@#{pr_author}](#{pr_author_url})."
    #   end
    # end
  end
end
