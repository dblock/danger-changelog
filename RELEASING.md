# Releasing Danger-Changelog

This workflow follows [Danger-Toc](https://github.com/dblock/danger-toc/blob/master/RELEASING.md) and [CanonicalEmails](https://github.com/dblock/canonical-emails/blob/master/RELEASING.md). Publishing requires repository push access and RubyGems ownership with MFA enabled. Never commit credentials or OTP codes.

## Prepare

Start from clean, current master using Ruby 3.1 or newer, compatible with the resolved ActiveSupport version:

```sh
git checkout master
git pull --ff-only origin master
```

Follow [Semantic Versioning](https://semver.org/); during 0.x development, increment the minor version for breaking changes and describe them explicitly. Ensure `lib/changelog/gem_version.rb` matches the upcoming CHANGELOG.md section. Date that section (`YYYY-MM-DD`), remove the contribution placeholder and extra blank lines within the release list, and review compatibility changes.

Run the full validation once immediately before committing and push directly on master, without a release-preparation PR:

```sh
bundle exec rake spec
git add CHANGELOG.md lib/changelog/gem_version.rb
git commit -m "Prepare release VERSION"
git push origin master
```

Use the intended version in place of VERSION throughout this guide. Confirm the release commit's full Ruby/ActiveSupport matrix and lint CI pass. Build and inspect the package from the clean release commit:

```sh
bundle exec rake build
tar -xOf pkg/danger-changelog-VERSION.gem data.tar.gz | tar -tzf -
```

The package should contain library files and published documentation, not specs, credentials, or local artifacts.

## Publish and Verify

Ask the maintainer for a fresh RubyGems OTP immediately before publishing, entering it when prompted. Never store it in files or commit it:

```sh
gem push pkg/danger-changelog-VERSION.gem
curl --fail --silent --show-error https://rubygems.org/api/v2/rubygems/danger-changelog/versions/VERSION.json
```

Verify the exact version using the API; remote gem listings may lag. If upload fails or its result is unclear, check publication state before retrying the existing package. Never overwrite a published version.

After successful publication, create and push an annotated tag. Never move an existing pushed tag:

```sh
git tag -a vVERSION -m "Version VERSION"
git push origin vVERSION
git ls-remote --tags origin 'vVERSION*'
gh release create vVERSION --verify-tag --title VERSION --notes-file RELEASE_NOTES
```

RELEASE_NOTES should contain only that version's changelog entries, not the entire changelog. Verify the published gem version, tag commit, and GitHub release before continuing. A GitHub release does not publish to RubyGems.

## Next Development Version

Increment the patch version in `lib/changelog/gem_version.rb` and prepend a matching `(Next)` changelog section containing `* Your contribution here.`. Run `bundle exec rake spec`, commit, and push directly to master without a PR or new tag. Leave master clean and ready for development. Do not merge or publish unless requested.
