module Danger
  # Enforce CHANGELOG.md O.C.D. in your projects.
  #
  # This plugin can, for example, make sure the changes are attributes properly and that they are always terminated with a period.
  #
  # @example Run all checks on the default CHANGELOG.md.
  #
  #          changelog.check
  #
  # @example Customize the CHANGELOG file name and remind the requester to update it when necessary.
  #
  #          changelog.filename = 'CHANGES.md'
  #          changelog.have_you_updated_changelog?
  #
  # @see  dblock/danger-changelog
  # @tags changelog

  class DangerChangelog < Plugin
    # The changelog file name, defaults to `CHANGELOG.md`.
    # @return   [String]
    attr_accessor :filename

    def initialize(dangerfile)
      @filename = 'CHANGELOG.md'
      super
    end

    # Run all checks.
    # @param format [Symbol] the format to check against
    # @return [Boolean] true when the check passes
    def check(format = Danger::Changelog::Parsers.default_format)
      have_you_updated_changelog? && is_changelog_format_correct?(format)
    end

    # Has the CHANGELOG file been modified?
    # @return [boolean]
    def changelog_changes?
      git.modified_files.include?(filename) || git.added_files.include?(filename)
    end

    # Have you updated CHANGELOG.md?
    # @return [boolean]
    def have_you_updated_changelog?
      if changelog_changes?
        true
      else
        markdown <<-MARKDOWN
Here's an example of a #{filename} entry:

```markdown
#{Danger::Changelog::ChangelogEntryLine.example(github)}
```
        MARKDOWN
        warn "Unless you're refactoring existing code or improving documentation, please update #{filename}.", sticky: false
        false
      end
    end

    # Is the CHANGELOG.md format correct?
    # @return  [boolean]
    def is_changelog_format_correct?(format)
      parser = Danger::Changelog::Parsers.lookup(format)
      changelog_file = Danger::Changelog::ChangelogFile.new(filename, parser: parser)

      if changelog_file.exists?
        changelog_file.parse
        changelog_file.bad_lines.each do |line|
          markdown <<-MARKDOWN
```markdown
#{line}```
          MARKDOWN
        end
        messaging.fail(parser.bad_line_message(filename), sticky: false) if changelog_file.bad_lines?

        changelog_file.global_failures.each do |failure|
          messaging.fail(failure, sticy: false)
        end

        changelog_file.good?
      else
        messaging.fail("The #{filename} file does not exist.", sticky: false)
        false
      end
    end
  end
end
