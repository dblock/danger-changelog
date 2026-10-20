module Danger
  module Changelog
    class UnreleasedSection
      def initialize(markdown, heading:)
        @lines = markdown.lines
        @heading = heading
      end

      def misplaced_entries(patch)
        allowed = entry_sections
        added_lines(patch).select { |number| @lines[number - 1]&.match?(/^[*-]\s/) && !allowed[number] }
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

      def added_lines(patch)
        number = nil
        added = []
        patch.each_line do |line|
          if (hunk = line.match(/^@@ -\d+(?:,\d+)? \+(\d+)(?:,\d+)? @@/))
            number = hunk[1].to_i
          elsif number && line.start_with?('+', ' ')
            added << number if line.start_with?('+')
            number += 1
          end
        end
        added
      end
    end
  end
end
