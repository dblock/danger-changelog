module Danger
  module Changelog
    # A CHANGELOG.md file reader.
    module ChangelogLine
      # match the PR format, with or without PR number
      def self.valid?(line)
        return true if line =~ %r{^\*\s[\`[:upper:]].* \- \[\@[\w\d\-\_]+\]\(https:\/\/github\.com\/.*[\w\d\-\_]+\)\.$}
        return true if line =~ %r{^\*\s\[\#\d+\]\(https:\/\/github\.com\/.*\d+\)\: [\`[:upper:]].* \- \[\@[\w\d\-\_]+\]\(https:\/\/github\.com\/.*[\w\d\-\_]+\)\.$}
        false
      end

      # provide an example of a CHANGELOG line based on a commit message
      def self.example(github)
        pr_number = github.pr_json[:number]
        pr_url = github.pr_json[:html_url]
        pr_title = github.pr_title
        pr_author = github.pr_author
        pr_author_url = "https://github.com/#{github.pr_author}"
        "* [##{pr_number}](#{pr_url}): #{pr_title} - [@#{pr_author}](#{pr_author_url})."
      end
    end
  end
end
