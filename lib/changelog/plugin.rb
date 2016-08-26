module Danger
  # CHANGELOG OCD in your projects.
  #
  # @example Checking for everuthing
  #
  #          changelog.check
  #
  # @see  dblock/danger-changelog
  # @tags changelog

  class DangerChangelog < Plugin
    # Has the CHANGELOG file been modified?
    # @return [boolean]
    def has_changelog_changes?
      git.modified_files.include?('CHANGELOG.md')
    end

    # Runs all checks.
    # @return [void]
    def check
      have_you_updated_changelog?
    end

    # Have you updated CHANGELOG.md?
    # @return [boolean]
    def have_you_updated_changelog?
      if has_changelog_changes?
        true
      else
        markdown <<-MARKDOWN
Here's an example of a CHANGELOG.md entry:

```markdown
* [##{github.pr_json[:number]}](#{github.pr_json[:html_url]}): #{github.pr_title} - [@#{github.pr_author}](https://github.com/#{github.pr_author}).
```
MARKDOWN
        warn "Unless you're refactoring existing code, please update CHANGELOG.md.", sticky: false
        false
      end
    end
  end
end
