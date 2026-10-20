require 'changelog/changelog_line/changelog_entry_line'

module Danger
  module Changelog
    class MarkdownReferences
      LABEL = /(?:\\.|[^\[\]\\\n])/
      TITLE = /(?:"[^"\n]*"|'[^'\n]*'|\([^)\n]*\))/
      DEFINITION = /^ {0,3}\[(?<label>#{LABEL}+)\]:[ \t]*(?:\r?\n[ \t]*)?(?:<(?<angle>[^<>\n]+)>|(?<url>\S+?))(?:(?:[ \t]+|[ \t]*\r?\n[ \t]+)#{TITLE})?[ \t]*\r?$/
      PR_REFERENCE = /\A(?<prefix>\*\s)(?<link>\[\#\d+\](?:\[#{LABEL}*\])?)(?=[:\s])/
      AUTHOR_REFERENCE = /(?<prefix> - )(?<link>\[@#{ChangelogEntryLine::AUTHOR_NAME}\](?:\[#{LABEL}*\])?)(?<suffix>\.?[ \t]*\r?\n?)\z/
      LINK = /\A\[(?<text>.+?)\](?:\[(?<label>#{LABEL}*)\])?\z/

      attr_reader :lines

      def initialize(markdown)
        @definitions = {}
        @lines = markdown.gsub(DEFINITION) do
          match = Regexp.last_match
          @definitions[normalize(match[:label])] ||= match[:angle] || match[:url]
          "\n" * match[0].count("\n")
        end.lines
      end

      def resolve(line)
        errors = []
        expanded = line.sub(PR_REFERENCE) do
          match = Regexp.last_match
          "#{match[:prefix]}#{resolve_link(match[:link], errors)}"
        end
        expanded = expanded.sub(AUTHOR_REFERENCE) do
          match = Regexp.last_match
          "#{match[:prefix]}#{resolve_link(match[:link], errors)}#{match[:suffix]}"
        end
        [expanded, errors]
      end

      private

      def normalize(label)
        label.gsub(/\\([[:punct:]])/, '\1').strip.gsub(/[[:space:]]+/, ' ').downcase
      end

      def resolve_link(link, errors)
        match = LINK.match(link)
        label = match[:label]
        label = match[:text] if label.nil? || label.empty?
        url = @definitions[normalize(label)]
        unless url
          errors << "undefined Markdown reference: [#{label}]"
          return link
        end

        "[#{match[:text]}](#{url})"
      end
    end
  end
end
