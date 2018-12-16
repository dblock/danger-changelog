# danger-changelog

A plugin for [danger.systems](http://danger.systems) that obsessive-compulsively lints your project’s `CHANGELOG.md`.
It can make sure, for example, that changes are attributed properly, have a valid version number, a date in the ISO8601 format, and that they’re always terminated with a period.

[![Gem Version](https://badge.fury.io/rb/danger-changelog.svg)](https://badge.fury.io/rb/danger-changelog)
[![Build Status](https://travis-ci.org/dblock/danger-changelog.svg?branch=master)](https://travis-ci.org/dblock/danger-changelog)

## Installation

Add `danger-changelog` to your Gemfile.

```
gem 'danger-changelog', '~> 0.3.0'
```

Add `changelog.check` to your `Dangerfile`. Make a pull request and see this plugin in action.

## Usage

Methods and attributes from this plugin are available in your `Dangerfile` under the `changelog` namespace.

### Configuration

You can configure the plugin in `Dangerfile`.

```ruby
Danger::Changelog.configure do |config|
  config.placeholder_line = "Nothing yet."
end
```

The following options are supported.

#### placeholder_line

Customize the `* Your contribution here.` line. Set the value to `nil` to stop checking for one.

### changelog.filename

Set the CHANGELOG file name, defaults to `CHANGELOG.md`.

### changelog.check

Run all checks with defaults.

#### changelog.have_you_updated_changelog?

Checks whether you have updated CHANGELOG.md.

![](images/have_you_updated_changelog.png)

#### changelog.is_changelog_format_correct?

Checks whether the CHANGELOG format is correct.

![](images/is_changelog_format_correct.png)

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md).

## Copyright

Copyright (c) Daniel Doubrovkine, 2016

MIT License, see [LICENSE](LICENSE.txt) for details.
