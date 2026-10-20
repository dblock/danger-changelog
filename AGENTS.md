# Working on danger-changelog

Danger plugin for changelog reminders and validation. Requires Ruby 3.1 or newer.

## Structure

* `lib/changelog/plugin.rb`: Danger checks, configuration delegation, and reports.
* `lib/changelog/config.rb`: declared options, validated global defaults, immutable per-check snapshots, and parser selection.
* `lib/changelog/parsers/`: Intridea and Keep a Changelog validation.
* `lib/changelog/changelog_line/`: Intridea line classification and diagnostics.
* `lib/changelog/pr_metadata.rb`: pull request metadata and local examples.
* `spec/`: RSpec examples and format fixtures.

## Development

Run `bundle exec rake spec` before committing; it runs RSpec, RuboCop, and plugin documentation lint. Use focused RSpec selectors while debugging. Install dependencies only when needed. CI covers Ruby 3.1 through 4.0 with compatible ActiveSupport versions; use `ACTIVESUPPORT_VERSION` to select one. Load logger after Bundler setup and before Danger for older ActiveSupport versions.

Preserve existing format rules unless a behavior change is explicitly requested. Test each supported parser affected by a change. Declare every option in Config::DEFAULTS and validate it in Config; generated global accessors and per-check keywords must support the same options. Pass immutable snapshots through parsing, placeholder validation, and reports; never read global defaults during a check. Reset global configuration between examples and keep provider-specific metadata optional so local checks work without API credentials.

Update README.md and format documentation for public behavior, keep the README TOC accurate, and keep Markdown paragraphs on one line. Add changelog entries under the next version with PR numbers and contributor attribution; retain the contribution placeholder.

## Git and releases

Use feature branches and one commit per PR. Amend updates with `--force-with-lease`, never force-push master. Leave issues open for their implementation PRs to close on merge. Do not merge or publish without explicit authorization. Follow RELEASING.md for authorized releases and next-version preparation directly on master. Never commit credentials or OTP codes.
