module Danger
  module Changelog
    # A CHANGELOG.md line represents the version header.
    class ChangelogHeaderLine < ChangelogLine
      OPEN_PARENS = /[(\[{]?/
      CLOSE_PARENS = /[)\]}]?/

      HASHES = /\#{1,4}/
      SEMVER = /(?<semver>(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?)/
      RELAXED_VERSION = /(?:0|[1-9]\d*)(?:\.(?:0|[1-9]\d*))+(?:-[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?(?:\+[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?/
      ISO8601_DATETIME = %r{(?<datetime>([0-9]{4})[-/]?(1[0-2]|0?[1-9])[-/]+(3[01]|0?[1-9]|[12][0-9])(T[0-9]{2}:[0-9]{2}:[0-9]{2})?Z?)}

      def valid?
        stripped_line = line.strip
        version = config.strict_semver ? SEMVER : RELAXED_VERSION

        m = title_valid?(stripped_line) # title
        m ||= stripped_line.match(/^#{HASHES}\s#{OPEN_PARENS}#{version}#{CLOSE_PARENS}$/) # version only
        m ||= stripped_line.match(/^#{HASHES}\s#{OPEN_PARENS}#{version}#{CLOSE_PARENS}[\s-]+#{OPEN_PARENS}(#{ISO8601_DATETIME}|#{labels})#{CLOSE_PARENS}$/) # version and date or next version description

        !!m && balanced?(stripped_line)
      end

      def self.validates_as_changelog_line?(line)
        return true if line =~ /^#{HASHES}\s.+/

        false
      end

      private

      def labels
        config.unreleased_labels ? Regexp.union(config.unreleased_labels) : /\w*/
      end

      def title_valid?(title)
        if config.unreleased_labels && (match = title.match(/^#{HASHES}\s[(\[{](.*)[)\]}]$/))
          config.unreleased_labels.include?(match[1])
        else
          title.match?(/^#{HASHES}\s#{OPEN_PARENS}[\w\s:]*#{CLOSE_PARENS}$/)
        end
      end
    end
  end
end
