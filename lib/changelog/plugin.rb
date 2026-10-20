require 'changelog/unreleased_section'
require 'changelog/added_lines'

module Danger
  # Enforce CHANGELOG.md O.C.D. in your projects.
  #
  # This plugin can, for example, make sure the changes are attributes properly and that they are always terminated with a period.
  #
  # @example Run all checks on the default CHANGELOG.md.
  #
  #          changelog.check!
  #
  # @example Customize the CHANGELOG file name and remind the requester to update it when necessary.
  #
  #          changelog.filename = 'CHANGES.md'
  #          changelog.placeholder_line = "* Your contribution here.\n"
  #          changelog.have_you_updated_changelog?
  #
  # @see  dblock/danger-changelog
  # @tags changelog

  class DangerChangelog < Plugin
    extend Forwardable

    def_delegators 'Danger::Changelog.config', *Danger::Changelog::Config::DELEGATORS

    # Run all checks.
    # @param [Hash] options per-check overrides for global settings
    # @return [Boolean] true when the check passes
    def check!(**options)
      config = Danger::Changelog.config.with(**options)
      updated_changelog?(config) && correct_changelog_format?(config) && unreleased_entries?(config) && correct_intent?(config)
    end

    # Run all checks.
    # @param [Symbol, String] parser the parser to check with
    # @param [Hash] options per-check overrides for global settings
    # @return [Boolean] true when the check passes
    def check(parser = Danger::Changelog.config.format, **options)
      warn '[DEPRECATION] `check` is deprecated. Set format with `.format` and use `check!` instead.'
      check!(format: parser, **options)
    end

    # Has the CHANGELOG file been modified?
    # @param [Hash] options per-check overrides for global settings
    # @return [boolean]
    def changelog_changes?(**options)
      changed_changelog?(Danger::Changelog.config.with(**options))
    end

    # Are any files CHANGELOG cares about modified?
    # @param [Hash] options per-check overrides for global settings
    # @return [boolean]
    def file_changes?(**options)
      changed_files?(Danger::Changelog.config.with(**options))
    end

    # Have you updated CHANGELOG.md?
    # @param [Hash] options per-check overrides for global settings
    # @return [boolean]
    def have_you_updated_changelog?(**options)
      updated_changelog?(Danger::Changelog.config.with(**options))
    end

    # Is the CHANGELOG.md format correct?
    # @param [Hash] options per-check overrides for global settings
    # @return [boolean]
    def is_changelog_format_correct?(**options)
      correct_changelog_format?(Danger::Changelog.config.with(**options))
    end

    # Require added list entries to belong to an unreleased section by default.
    # @param [Hash] options per-check overrides for global settings
    # @return [Boolean] true when entries are in the configured section
    def entries_in_unreleased_section?(**options)
      unreleased_entries?(Danger::Changelog.config.with(**options))
    end

    # Check entries against the optional intent-word dictionary and verb-family consistency rules.
    # @param [Hash] options per-check overrides for global settings
    # @return [Boolean] true when selected entries use allowed and consistent intent words
    def intent_correct?(**options)
      correct_intent?(Danger::Changelog.config.with(**options))
    end

    private

    def unreleased_entries?(config)
      return true unless config.unreleased_heading && changed_changelog?(config)

      diff = git.diff_for_file(config.filename)
      unless diff
        messaging.fail("Cannot inspect the diff for #{config.filename}.", sticky: false)
        return false
      end

      section = Danger::Changelog::UnreleasedSection.new(File.read(config.filename), heading: config.unreleased_heading)
      misplaced = section.misplaced_entries(diff.patch)
      return true if misplaced.empty?

      messaging.fail("Added changelog entries outside the unreleased section in #{config.filename} at lines #{misplaced.join(', ')}.", sticky: false)
      false
    end

    def correct_intent?(config)
      return true unless config.check_intent

      unless File.exist?(config.filename)
        messaging.fail("The #{config.filename} file does not exist.", sticky: false)
        return false
      end

      added_lines = entry_added_lines(config)
      return false if config.only_added && added_lines.nil?

      failures = Danger::Changelog::IntentCheck.new(File.read(config.filename), config: config).failures(added_lines: added_lines)
      failures.each do |number, detail|
        messaging.fail("#{config.filename}:#{number}: #{detail}", sticky: false)
      end
      failures.empty?
    end

    def changed_changelog?(config)
      git.modified_files.include?(config.filename) || git.added_files.include?(config.filename)
    end

    def changed_files?(config)
      all_files = git.modified_files + git.added_files
      config.ignore_files.each do |f|
        all_files.reject! { |modified_file| f.is_a?(Regexp) ? f.match?(modified_file) : f == modified_file }
        break if all_files.empty?
      end
      all_files.any?
    end

    def updated_changelog?(config)
      if changed_changelog?(config)
        true
      elsif changed_files?(config)
        warn_update_changelog(config.filename)
        false
      else
        true
      end
    end

    def correct_changelog_format?(config)
      filename = config.filename
      unless File.exist?(filename)
        messaging.fail("The #{filename} file does not exist.", sticky: false)
        return false
      end

      added_lines = entry_added_lines(config)
      return false if config.only_added && added_lines.nil?

      parser = config.parser(added_lines: added_lines)
      changelog_file = Danger::Changelog::ChangelogFile.new(filename, parser: parser)

      if changelog_file.exists?
        changelog_file.parse
        changelog_file.bad_lines.each do |line|
          markdown code_block(line.map(&:strip).join("\n"))
        end
        messaging.fail(parser.bad_line_message(filename), sticky: false) if changelog_file.bad_lines?

        changelog_file.global_failures.each do |failure|
          messaging.fail(failure, sticky: false)
        end

        changelog_file.good?
      else
        messaging.fail("The #{filename} file does not exist.", sticky: false)
        false
      end
    end

    def pr_metadata
      Danger::Changelog::PRMetadata.from_event_file(ENV.fetch('GITHUB_EVENT_PATH', nil)) ||
        Danger::Changelog::PRMetadata.from_github_plugin(github_plugin) ||
        Danger::Changelog::PRMetadata.from_gitlab_plugin(gitlab_plugin) ||
        Danger::Changelog::PRMetadata.fallback
    end

    def entry_added_lines(config)
      return nil unless config.only_added
      return [] unless changed_changelog?(config)

      diff = git.diff_for_file(config.filename)
      return Danger::Changelog::AddedLines.from_patch(diff.patch) if diff

      messaging.fail("Cannot inspect the diff for #{config.filename}.", sticky: false)
      nil
    end

    def code_block(content)
      fence = '`' * [3, content.scan(/`+/).map(&:length).max.to_i + 1].max
      "#{fence}markdown\n#{content}\n#{fence}\n"
    end

    def github_plugin
      github
    rescue NoMethodError => e
      # github plugin is not available in dry_run mode (LocalOnly request source)
      raise unless e.name == :github

      nil
    end

    def gitlab_plugin
      gitlab
    rescue NoMethodError => e
      raise unless e.name == :gitlab

      nil
    end

    def warn_update_changelog(filename)
      example = Danger::Changelog::ChangelogEntryLine.example(pr_metadata)

      markdown <<~MARKDOWN
        ### Suggested changelog entry

        Here's an example of a #{filename} entry:

        ```markdown
        #{example}
        ```
      MARKDOWN
      warn "Unless you're refactoring existing code or improving documentation, please update #{filename}.", sticky: false
    end
  end
end
