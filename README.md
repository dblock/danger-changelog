# Danger-Changelog

A plugin for [danger.systems](https://danger.systems) that obsessive-compulsively lints your project’s `CHANGELOG.md`. It can make sure, for example, that changes are attributed properly, have a valid version number, a date in the ISO8601 format, balanced parenthesis and brackets, and that they’re always terminated with a period.

[![Gem Version](https://badge.fury.io/rb/danger-changelog.svg)](https://badge.fury.io/rb/danger-changelog)
[![Build Status](https://github.com/dblock/danger-changelog/actions/workflows/test.yml/badge.svg?branch=master&event=push)](https://github.com/dblock/danger-changelog/actions/workflows/test.yml)

# Table of Contents

- [What’s a correctly formatted CHANGELOG file?](#whats-a-correctly-formatted-changelog-file)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
  - [changelog.filename](#changelogfilename)
  - [changelog.format](#changelogformat)
  - [changelog.placeholder_line](#changelogplaceholder_line)
  - [changelog.ignore_files](#changelogignore_files)
  - [changelog.strict_semver](#changelogstrict_semver)
  - [changelog.unreleased_heading](#changelogunreleased_heading)
  - [changelog.only_added](#changelogonly_added)
  - [Conditional reminders](#conditional-reminders)
- [Checks](#checks)
  - [changelog.check!](#changelogcheck)
    - [changelog.have_you_updated_changelog?](#changeloghave_you_updated_changelog)
    - [changelog.is_changelog_format_correct?](#changelogis_changelog_format_correct)
- [Contributing](#contributing)
- [Copyright](#copyright)

## What's a correctly formatted CHANGELOG file?

By design, `danger-changelog` is quite strict with what it allows as a valid changelog file, using the [Intridea style](doc/intridea.md), [used by this library itself](CHANGELOG.md). It also supports the [Keep a Changelog](doc/keep_a_changelog.md) format.

Intridea PR and author links can be inline links or [Markdown references](doc/intridea.md#changelog-entries), with definitions elsewhere in the file. Undefined references are reported without changing the original entry shown in the report.

## Installation

Requires Ruby 3.1 or newer. Add `danger-changelog` to your Gemfile.

```
gem 'danger-changelog'
```

Call `changelog.check!` from your `Dangerfile`. Make a pull request and see this plugin in action.

## Usage

Methods and attributes from this plugin are available in your `Dangerfile` under the `changelog` namespace.

## Configuration

Every option can be set globally on `changelog` or passed as a keyword to a check. Per-check keywords override global defaults only for that call; parsing and reports use an immutable snapshot. Unknown options and invalid values raise `ArgumentError`.

```ruby
changelog.ignore_files = ['README.md', /\.txt$/]
changelog.check!
changelog.check!(filename: 'packages/api/CHANGELOG.md')
changelog.check!(filename: 'CHANGES.md', format: :keep_a_changelog)
```

Global strings and arrays are copied and frozen; assign a new value rather than modifying a setting in place. The deprecated `Danger::Changelog.configure` block still sets global defaults.

### changelog.filename

Set the CHANGELOG file name, defaults to `CHANGELOG.md`.

```ruby
changelog.filename = 'CHANGES.md'
changelog.check!(filename: 'CHANGES.md')
```

### changelog.format

Set the format of the CHANGELOG file.

```ruby
changelog.format = :keep_a_changelog
changelog.check!(format: :keep_a_changelog)
```

Available formats are [Intridea](doc/intridea.md) (default) and [Keep a Changelog](doc/keep_a_changelog.md). Symbol and string format names are accepted.

### changelog.placeholder_line

Customize the `* Your contribution here.` line. Set the value to `nil` to stop checking for one.

```ruby
changelog.placeholder_line = "* Your change here.\n"
changelog.check!(placeholder_line: 'Your change here.')
```

The leading `* ` and trailing newline are added when omitted. This option applies to the Intridea parser; Keep a Changelog does not require a placeholder.

### changelog.ignore_files

Ignore additions and changes with a certain name or expression, default is to ignore `README.md` changes.

For example, ignore `UPGRADING.md` and all `.txt` files.

```ruby
changelog.ignore_files = ['README.md', 'UPGRADING.md', /\.txt$/]
changelog.check!(ignore_files: ['README.md', 'UPGRADING.md', /\.txt$/])
```

### changelog.strict_semver

Require three-component Semantic Versions by default. Set `strict_semver: false` to accept numeric versions with two or more components, such as `2.0` or `1.2.3.4`, with optional prerelease/build suffixes. Date, delimiter, and other formatting checks remain active. This applies to both supported formats.

```ruby
changelog.strict_semver = false
changelog.check!(filename: 'CHANGES.md', strict_semver: false)
```

### changelog.unreleased_heading

By default, added list entries must belong to an unreleased section. The default heading pattern, `/(?:\(Next\)|\[Unreleased\])/i`, recognizes Intridea's `(Next)` and Keep a Changelog's `[Unreleased]`, case-insensitively. This global or per-check setting applies to both formats and is enforced by `check!` after its existing checks pass:

```ruby
changelog.unreleased_heading = /\(Next\)/
changelog.check!
changelog.check!(format: :keep_a_changelog, unreleased_heading: /\[Unreleased\]/i)
changelog.check!(unreleased_heading: nil) # Allow intentional historical corrections.
```

Only added `*` or `-` list lines in Danger's changelog diff are checked. Nested category headings stay inside the release; the next heading at the same or shallower level ends it. Unchanged historical entries are ignored. Historical corrections appear as additions too; use `unreleased_heading: nil` for those PRs and release-preparation changes. Customize the pattern for your project's heading convention.

Call `changelog.entries_in_unreleased_section?(unreleased_heading: /\(Next\)/)` to run this check separately. Missing diff data produces an explicit error rather than silently skipping the enabled check.

### changelog.only_added

Format validation checks the entire file by default (`only_added: false`). Set `only_added: true` globally or per check to report line-level format problems only on added lines in Danger's diff. Edited historical entries count as additions. Headers, punctuation, capitalization, attribution, and reference diagnostics follow this scope; reference definitions elsewhere in the file remain available for resolution.

```ruby
changelog.only_added = true
changelog.check!
changelog.is_changelog_format_correct?(only_added: false)
```

Missing files, required placeholders, and Keep a Changelog preamble requirements always apply to the whole file. Missing diff data is an explicit failure when added-only checking is requested for a changed changelog. An unchanged file has no added-line diagnostics but still receives global checks.

Release-section placement always checks additions only, regardless of `only_added`; checking released history against an unreleased section would incorrectly reject existing releases. Use `unreleased_heading: nil` to disable placement validation.

### Conditional reminders

By default, only `README.md` is ignored. To skip reminders when all added or modified files are documentation at the repository root, use an anchored pattern. Subdirectory files still require a changelog update.

```ruby
changelog.ignore_files = [/\A[^\/]+\.md\z/]
changelog.check!
```

For code-only reminders, use Danger's changed files directly. Keep format validation unconditional, so an edited changelog is checked even when no code changes:

```ruby
changed_files = git.modified_files + git.added_files + git.deleted_files
changelog.have_you_updated_changelog? if changed_files.any? { |file| file.start_with?('lib/') }
changelog.is_changelog_format_correct?
```

Other policies can use the same separate checks, such as reminding only for changes larger than 50 lines unless the pull request is marked trivial:

```ruby
declared_trivial = github.pr_labels.include?('trivial')
changelog.have_you_updated_changelog? if git.lines_of_code > 50 && !declared_trivial
changelog.is_changelog_format_correct?
```

The label example uses the GitHub plugin; adapt the condition to your provider. Do not also call `check!` in these conditional examples, because it would run the reminder unconditionally.

## Checks

All checks accept the same configuration keywords: `filename`, `format`, `placeholder_line`, `ignore_files`, `strict_semver`, `unreleased_heading`, and `only_added`. Each uses only the relevant settings.

### changelog.check!

Run all checks with defaults, including `have_you_updated_changelog?`, `is_changelog_format_correct?`, and `entries_in_unreleased_section?`.

```ruby
changelog.check!(filename: 'CHANGES.md', placeholder_line: nil)
```

As before, format validation runs only if the update reminder passes. The deprecated `check` also accepts keyword overrides and its legacy positional format, without modifying global defaults.

#### changelog.have_you_updated_changelog?

Checks whether you have updated CHANGELOG.md.

```ruby
changelog.have_you_updated_changelog?(filename: 'CHANGES.md', ignore_files: [/\.md$/])
```

![](images/have_you_updated_changelog.png)

#### changelog.is_changelog_format_correct?

Checks whether the CHANGELOG format is correct.

```ruby
changelog.is_changelog_format_correct?(filename: 'CHANGES.md', format: :keep_a_changelog)
```

The change predicates `changelog_changes?` and `file_changes?` accept the same keywords, for example `changelog.changelog_changes?(filename: 'CHANGES.md')`.

![](images/is_changelog_format_correct.png)

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md).

## Copyright

Copyright (c) Daniel Doubrovkine, 2016-2019

MIT License, see [LICENSE](LICENSE.txt) for details.
