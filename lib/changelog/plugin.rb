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
    # @return [void]
    def check
      have_you_updated_changelog?
      is_changelog_format_correct?
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
#{Danger::Changelog::ChangelogLine.example(github)}
```
MARKDOWN
        warn "Unless you're refactoring existing code, please update #{filename}.", sticky: false
        false
      end
    end

    # Is the CHANGELOG.md format correct?
    def is_changelog_format_correct?
      changelog_file = Danger::Changelog::ChangelogFile.new(filename)
      if changelog_file.exists?
        changelog_file.bad_lines.each do |line|
          markdown <<-MARKDOWN
```markdown
#{line}```
MARKDOWN
        end
        messaging.fail("One of the lines below found in #{filename} doesn't match the expected format. Please make it look like the other lines, pay attention to periods and spaces.", sticky: false) if changelog_file.bad_lines?
        messaging.fail("Please put back the `* Your contribution here.` line into #{filename}.", sticky: false) unless changelog_file.your_contribution_here?
        changelog_file.good?
      else
        messaging.fail('The #{filename} file does not exist.', sticky: false)
        false
      end
    end
  end
end
