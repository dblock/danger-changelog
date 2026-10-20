require 'changelog/added_lines'

module Danger
  module Changelog
    class UnreleasedSection
      def initialize(markdown, heading:)
        @lines = markdown.lines
        @heading = heading
      end

      def misplaced_entries(patch)
        allowed = entry_sections
        AddedLines.from_patch(patch).select { |number| @lines[number - 1]&.match?(/^[*-]\s/) && !allowed[number] }
      end

      private

      def entry_sections
        level = nil
        active = false
        @lines.each_with_index.to_h do |line, index|
          header = line.match(/^(#+)\s/)
          if header && @heading.match?(line)
            level = header[1].length
            active = true
          elsif header && level && header[1].length <= level
            active = false
          end
          [index + 1, active]
        end
      end
    end
  end
end
