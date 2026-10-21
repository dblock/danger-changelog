# Intridea Style

The Intridea style changelog was pioneered on the Hashie project. It has many elements that can you use and prevents some other elements as follows.

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

### Unreleased labels

Version headers can use labels such as `## 0.4.0 (Next)` or `## 0.4.0 (next)` by default. To enforce one spelling, set `changelog.unreleased_labels = ['Next']` or pass `unreleased_labels: ['Next']` to a check. This replaces permissive label matching with an exact, case-sensitive list and also applies to standalone delimited labels such as `## [Next]`. Dates, bare versions, and ordinary unwrapped titles are unaffected. The default `nil` preserves existing behavior; `[]` allows no labels. See [configuration](../README.md#changelogunreleased_labels).

### Changelog entries

✅ Under each title, you can have changelog entries in the format: `* {optional link to GitHub pull request that must be followed by a colon} {a single sentence of text description} - {author github link}.`:

```markdown
* Entry without a PR link - [@ivoanjo](https://github.com/ivoanjo).
* [#1](https://github.com/dblock/danger-changelog/pull/1): Entry with a PR link - [@dblock](https://github.com/dblock).
* [#2](https://github.com/dblock/danger-changelog/pull/2): Update dependencies - [@github-actions[bot]](https://github.com/apps/github-actions).
* Yes, this is a weird entry, but it's still valid! Also Beyoncé is welcome here, as is 松本 行弘 and our nice emojis 👍 - [@ivoanjo](https://github.com/ivoanjo).
```

Bot author names may end in a literal `[bot]` suffix, such as `github-actions[bot]` or `dependabot[bot]`. Keep the suffix in the attribution; links to GitHub app pages and bot profiles are supported.

✅ Entry descriptions can start with uppercase letters, uncased scripts (such as Japanese, Chinese, or Arabic), emoji, or inline code

```markdown
* 日本語の変更 - [@ivoanjo](https://github.com/ivoanjo).
* 修复问题 - [@ivoanjo](https://github.com/ivoanjo).
* 🚀 Add a feature - [@ivoanjo](https://github.com/ivoanjo).
```

✅ Pull request and author links may use Markdown references: full (`[@dblock][author]`), collapsed (`[@dblock][]`), or shortcut (`[@dblock]`)

```markdown
* [#1]: Fix an issue - [@dblock].
* [#2][second-pr]: Add a feature - [@dblock][author].

[#1]: https://github.com/dblock/danger-changelog/pull/1
[second-pr]: https://github.com/dblock/danger-changelog/pull/2
[@dblock]: https://github.com/dblock
[author]: https://github.com/dblock
```

Definitions may appear before or after entries. Labels are case-insensitive and consecutive whitespace is collapsed; the first definition wins when a label is repeated. Angle-bracket destinations and optional titles are accepted, including an indented destination or title on the following line. Inline links and reference links can be mixed. Bot links can use a named reference such as `[@dependabot[bot]][bot]`.

Undefined references are reported explicitly. Resolved destinations must satisfy the same GitHub URL rules as inline links. Reports show the original entry, not its expanded form. Reference expansion applies to PR and author links, not arbitrary references or inline-code examples inside the description.

❌ When a description starts with a cased letter, that letter must be uppercase

```markdown
* not valid - [@ivoanjo](https://github.com/ivoanjo).
* écriture en minuscule - [@ivoanjo](https://github.com/ivoanjo).
* [#1](https://github.com/dblock/danger-changelog/pull/1): not valid - [@dblock](https://github.com/dblock).
```

❌ GitHub pull request links need to be followed with a colon

```markdown
* [#1](https://github.com/dblock/danger-changelog/pull/1) Not valid - [@dblock](https://github.com/dblock).
```

✅ GitHub pull requests and GitLab.com merge requests and author profiles are supported, including GitLab subgroups

```markdown
* [#1](https://gitlab.com/group/subgroup/project/-/merge_requests/1): Fix an issue - [@contributor](https://gitlab.com/contributor).
```

GitLab reminders use merge-request metadata for their suggested entries. Self-managed GitLab hosts are not currently accepted by the Intridea URL rules; Keep a Changelog accepts arbitrary link destinations.

❌ Links must use supported hosts and `https`

```markdown
* Unsupported host - [@ivoanjo](https://example.com/ivoanjo).
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
