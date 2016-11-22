module Danger
  module Changelog
    # A CHANGELOG.md file reader.
    class ChangelogFile
      attr_reader :filename, :bad_lines, :exists

      def initialize(filename = 'CHANGELOG.md')
        @filename = filename
        @exists = File.exist?(filename)
        parse if @exists
      end

      # Any bad_lines?
      def bad_lines?
        !!bad_lines && bad_lines.any?
      end

      def exists?
        !!@exists
      end

      def your_contribution_here?
        !!@your_contribution_here
      end

      def bad?
        bad_lines? || !your_contribution_here?
      end

      def good?
        !bad?
      end

      private

      # Parse CHANGELOG file.
      def parse
        @your_contribution_here = false
        @bad_lines = []
        File.open(filename).each_line do |line|
          changelog_line = ChangelogLineParser.parse(line)
          if line.nil? || !line.valid?
            @bad_lines << line
            next
          end

          # notice your contribution here
          if line.kind_of?(ChangelogPlaceholderLine)
            @your_contribution_here = true
            next
          end
        end
      end
    end
  end
end
