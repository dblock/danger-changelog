require 'changelog/markdown_references'

module Danger
  module Changelog
    class IntentCheck
      WORD_GROUPS = [
        %w[Add Added Adds Adding],
        %w[Allow Allowed Allows Allowing],
        %w[Change Changed Changes Changing],
        %w[Clarify Clarified Clarifies Clarifying],
        %w[Deprecate Deprecated Deprecates Deprecating],
        %w[Disable Disabled Disables Disabling],
        %w[Document Documented Documents Documenting],
        %w[Enable Enabled Enables Enabling],
        %w[Fix Fixed Fixes Fixing],
        %w[Improve Improved Improves Improving],
        %w[Optimize Optimized Optimizes Optimizing],
        %w[Refactor Refactored Refactors Refactoring],
        %w[Remove Removed Removes Removing],
        %w[Rename Renamed Renames Renaming],
        %w[Replace Replaced Replaces Replacing],
        %w[Revert Reverted Reverts Reverting],
        %w[Simplify Simplified Simplifies Simplifying],
        %w[Support Supported Supports Supporting],
        %w[Update Updated Updates Updating],
        %w[Upgrade Upgraded Upgrades Upgrading]
      ].map { |group| group.map(&:freeze).freeze }.freeze
      DEFAULT_WORDS = WORD_GROUPS.flatten.freeze

      def initialize(markdown, config:)
        @lines = markdown.lines
        @references = MarkdownReferences.new(markdown)
        @config = config
        @code_lines = code_lines
      end

      def failures(added_lines: nil)
        used = {}
        numbers = added_lines || (1..@lines.length)
        numbers.filter_map do |number|
          source = @lines[number - 1]
          next if @code_lines[number]
          next unless source&.match?(/^[*-]\s+/)
          next if source == @config.placeholder_line

          expanded, = @references.resolve(source.sub(/\A- /, '* '))
          description = expanded.sub(/^[*-]\s+/, '').sub(/\A#{ChangelogEntryLine::PR_LINK}:\s*/, '')
          word = description[/\A\p{L}+/]
          next [number, "Start the description with an allowed intent word: #{@config.intent_words.join(', ')}."] unless @config.intent_words.include?(word)

          group = WORD_GROUPS.find { |words| words.include?(word) }
          next unless group

          first_word, first_line = used[group] ||= [word, number]
          next if word == first_word

          [number, "Use '#{first_word}' consistently instead of '#{word}' (first used on line #{first_line})."]
        end
      end

      private

      def code_lines
        fence = nil
        @lines.each_with_index.to_h do |line, index|
          marker = line[/\A {0,3}(`{3,}|~{3,})/, 1]
          inside = !fence.nil?
          if marker && !fence
            fence = marker
          elsif fence && line.match?(/\A {0,3}#{Regexp.escape(fence[0])}{#{fence.length},}[ \t]*\r?\n?\z/)
            fence = nil
          end
          [index + 1, inside || !fence.nil?]
        end
      end
    end
  end
end
