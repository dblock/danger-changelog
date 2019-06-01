# frozen_string_literal: true

module Danger
  module Changelog
    # A CHANGELOG.md line represents the version header.
    class ChangelogHeaderLine < ChangelogLine
      OPEN_PARENS = /[\(\[\{]?/.freeze
      CLOSE_PARENS = /[\)\]\}]?/.freeze

      HASHES = /\#{1,4}/.freeze
      SEMVER = /(?<semver>(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?)/.freeze
      ISO8601_DATE = %r{(?<date>([0-9]{4})[-/]?(1[0-2]|0?[1-9])[-/]+(3[01]|0?[1-9]|[12][0-9]))}.freeze

      def valid?
        stripped_line = line.strip

        m = stripped_line.match(/^#{HASHES}\s#{OPEN_PARENS}[\w\s\:]*#{CLOSE_PARENS}$/) # title
        m ||= stripped_line.match(/^#{HASHES}\s#{OPEN_PARENS}#{SEMVER}#{CLOSE_PARENS}$/) # semver only
        m ||= stripped_line.match(/^#{HASHES}\s#{OPEN_PARENS}#{SEMVER}#{CLOSE_PARENS}[\s\-]+#{OPEN_PARENS}(#{ISO8601_DATE}|\w*)#{CLOSE_PARENS}$/) # semver and iso 8601 date or next version description

        !m.nil? && balanced?(stripped_line)
      end

      def self.validates_as_changelog_line?(line)
        return true if line =~ /^#{HASHES}\s.+/

        false
      end
    end
  end
end
