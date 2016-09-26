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
          # ignore lines that aren't changes
          next unless line[0] == '*'
          # notice your contribution here
          if line == "* Your contribution here.\n"
            @your_contribution_here = true
            next
          end
          next if Danger::Changelog::ChangelogLine.valid?(line)
          @bad_lines << line
        end
      end
    end
  end
end
