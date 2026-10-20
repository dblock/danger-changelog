require 'spec_helper'

describe Danger::Changelog::UnreleasedSection do
  let(:markdown) { "## [Unreleased]\n### Fixed\n* New change\n## 1.0.0\n### Fixed\n* Historical entry\n" }
  let(:section) { described_class.new(markdown, heading: /\[Unreleased\]/) }

  it 'allows additions under category subheadings of the unreleased section' do
    patch = "@@ -1,2 +1,3 @@\n ## [Unreleased]\n ### Fixed\n+* New change\n"
    expect(section.misplaced_entries(patch)).to eq([])
  end

  it 'reports additions in historical sections across multiple diff hunks' do
    patch = "@@ -1,2 +1,3 @@\n ## [Unreleased]\n ### Fixed\n+* New change\n@@ -4,1 +5,2 @@\n ### Fixed\n+* Historical entry\n"
    expect(section.misplaced_entries(patch)).to eq([6])
  end

  it 'does not flag unchanged historical entries or removed entries' do
    patch = "@@ -5,3 +5,2 @@\n ### Fixed\n-* Removed entry\n * Historical entry\n"
    expect(section.misplaced_entries(patch)).to eq([])
  end

  it 'rejects added entries when no unreleased heading matches' do
    section = described_class.new(markdown, heading: /\(Next\)/)
    expect(section.misplaced_entries("@@ -0,0 +3 @@\n+* New change\n")).to eq([3])
  end

  it 'ignores patch file headers and non-entry additions' do
    patch = "--- a/CHANGELOG.md\n+++ b/CHANGELOG.md\n@@ -0,0 +1,2 @@\n+## [Unreleased]\n+### Fixed\n"
    expect(section.misplaced_entries(patch)).to eq([])
  end
end
