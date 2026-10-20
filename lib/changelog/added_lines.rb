module Danger
  module Changelog
    module AddedLines
      def self.from_patch(patch)
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
