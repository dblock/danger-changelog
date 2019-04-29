# danger-changelog

A plugin for [danger.systems](http://danger.systems) that obsessive-compulsively lints your project’s `CHANGELOG.md`.
It can make sure, for example, that changes are attributed properly, have a valid version number, a date in the ISO8601 format, balanced parenthesis and brackets, and that they’re always terminated with a period.

[![Gem Version](https://badge.fury.io/rb/danger-changelog.svg)](https://badge.fury.io/rb/danger-changelog)
[![Build Status](https://travis-ci.org/dblock/danger-changelog.svg?branch=master)](https://travis-ci.org/dblock/danger-changelog)

## What's a correctly formatted CHANGELOG file?

By design, `danger-changelog` is quite strict with what it allows as a valid changelog file.

### Titles

✅ You can have up to four levels of titles

```markdown
# This is a title for my changelog
## lower case also works and so do numbers 123
### Colons: They are awesome
#### Probably not used all that often
```

❌ Only letters (a-z), numbers, underscores and colons are allowed in titles

```markdown
#### Emoji is not allowed 😢
#### Hyphens are not allowed thus sugar-free is not valid
#### Multiple sentences. Are not allowed
#### Commas, neither
#### No accented characters sorry Beyoncé
```

❌ Titles must start with a leading space

```markdown
#This is not valid
```

✅ You can place your titles inside a single parens

```markdown
# (This is allowed)
## [This is allowed]
### {This is also allowed}
```

❌ Parens in a title must match, and you can only have one set

```markdown
# (Not valid
## {Not valid)
### Not valid ()
#### [] Not valid
#### ((Not valid))
```

✅ You can have a [semantic-versioning](https://semver.org/) compatible version number

```markdown
# 1.0.0
## 1.0.0-alpha
### (3.2.1-beta+reallybuggy.1)
```

❌ Version numbers which do not follow [semantic-versioning](https://semver.org/) are not allowed

```markdown
# 01.0.0.notvalid
```

❌ You cannot combine version numbers with other text

```markdown
# Not valid 1.0.0
# Not valid (1.0.0)
```

✅ You can include an [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601)-formatted date along with a version, inside or outside parens

```markdown
# 1.0.0 2019
## 1.0.0 (2019-12-31)
### (1.0.0) (2019/12/31)
#### (1.0.0) 20191231
```

❌ No other date or time formats are allowed

```markdown
# 1.0.0 (2019-12)
# 1.0.0 (2019-W1)
# 1.0.0 (2019-04-28T09:21:58Z)
# 1.0.0 (31/12/2019)
```

❌ Dates cannot be combined with normal titles

```markdown
# Not valid (2019/12/31)
```

### Changelog entries

✅ Under each title, you can have changelog entries in the format: `* {optional link to GitHub pull request that must be followed by a colon} {a single sentence of text description} - {author github link}.`:

```markdown
* Entry without a PR link - [@ivoanjo](https://github.com/ivoanjo).
* [#1](https://github.com/dblock/danger-changelog/pull/1): Entry with a PR link - [@dblock](https://github.com/dblock).
* Yes, this is a weird entry, but it's still valid! Also Beyoncé is welcome here, as is 松本 行弘 and our nice emojis 👍 - [@ivoanjo](https://github.com/ivoanjo).
```

❌ Entry descriptions need to start with an uppercase A-Z letter

```markdown
* not valid - [@ivoanjo](https://github.com/ivoanjo).
* いいえ - [@ivoanjo](https://github.com/ivoanjo).
* ❌ - [@ivoanjo](https://github.com/ivoanjo).
* [#1](https://github.com/dblock/danger-changelog/pull/1): not valid - [@dblock](https://github.com/dblock).
```

❌ GitHub pull request links need to be followed with a colon

```markdown
* [#1](https://github.com/dblock/danger-changelog/pull/1) Not valid - [@dblock](https://github.com/dblock).
```

❌ Only links to GitHub are allowed, and only using `https`

```markdown
* No GitLab - [@ivoanjo](https://gitlab.com/ivoanjo).
* No insecure http - [@ivoanjo](http://github.com/ivoanjo).
* [#1](https://you-get-the-point.com): Entry with a PR link - [@dblock](https://github.com/dblock).
```
❌ Only a single sentence is allowed

```markdown
* Did stuff. Then more stuff - [@ivoanjo](https://github.com/ivoanjo).
```

❌ A dash needs to separate the text description from the author

```markdown
* Missing a dash here ➡️ [@ivoanjo](https://github.com/ivoanjo).
```

❌ An entry must end with a period

```markdown
* Not valid - [@ivoanjo](https://github.com/ivoanjo)
```

### Blank lines

✅ You can have them

```markdown

```

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
