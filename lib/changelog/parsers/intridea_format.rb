# frozen_string_literal: true

module Danger
  module Changelog
    module Parsers
      class IntrideaFormat < Base
        def bad_line_message(filename)
          "One of the lines below found in #{filename} doesn't match the " \
          '[expected format](https://github.com/dblock/danger-changelog/blob/master/README.md#whats-a-correctly-formatted-changelog-file). ' \
          'Please make it look like the other lines, pay attention to version ' \
          'numbers, periods, spaces and date formats.'
        end

        def parse(filename)
          your_contribution_here = false

          File.open(filename).each_line do |line|
            next if line.strip.empty?

            changelog_line = ChangelogLineParser.parse(line)

            if changelog_line.nil? || changelog_line.invalid?
              notify_of_bad_line line
              next
            end

            # notice your contribution here
            if changelog_line.is_a?(ChangelogPlaceholderLine)
              your_contribution_here = true
              next
            end
          end

          return if your_contribution_here
          return unless Danger::Changelog.config.placeholder_line?
          return unless (placeholder = Danger::Changelog.config.placeholder_line.chomp)

          notify_of_global_failure "Please put back the `#{placeholder}` line into #{filename}."
        end
      end
    end
  end
end
