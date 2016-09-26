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
    end
  end
end
