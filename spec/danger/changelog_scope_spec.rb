require 'spec_helper'
require 'tempfile'

describe Danger::Changelog do
  let(:changelog) { testing_dangerfile.changelog }

  def with_changelog(source, patch)
    Tempfile.create(['scope', '.md']) do |file|
      file.write(source)
      file.flush
      allow(changelog.git).to receive_messages(modified_files: [file.path], added_files: [], diff_for_file: Struct.new(:patch).new(patch))
      yield file.path
    end
  end

  it 'validates the full Intridea file by default and filters only line diagnostics when requested' do
    source = "## 1.0.0 (Next)\n* Your contribution here.\n* Bad old entry\n* Add feature - [@dblock](https://github.com/dblock).\n"
    with_changelog(source, "@@ -3 +3,2 @@\n * Bad old entry\n+* Add feature - [@dblock](https://github.com/dblock).\n") do |filename|
      expect(changelog.is_changelog_format_correct?(filename: filename)).to be false
      expect(changelog.check!(filename: filename, only_added: true)).to be true
      expect(changelog.only_added).to be false
    end
  end

  it 'uses line numbers rather than text to identify an invalid repeated entry' do
    with_changelog("## 1.0.0\n* Bad entry\n* Bad entry\n", "@@ -2 +2,2 @@\n * Bad entry\n+* Bad entry\n") do |filename|
      expect(changelog.is_changelog_format_correct?(filename: filename, only_added: true, placeholder_line: nil)).to be false
      expect(changelog.status_report[:markdowns].size).to eq(1)
    end
  end

  it 'keeps unchanged placeholders required when checking additions only' do
    with_changelog("## 1.0.0\n", '') do |filename|
      expect(changelog.is_changelog_format_correct?(filename: filename, only_added: true)).to be false
      expect(changelog.status_report[:errors].last).to include('Please put back')
    end
  end

  it 'applies global scope defaults with per-check override and reports missing diff data' do
    with_changelog("## 1.0.0\nInvalid old text\n", '') do |filename|
      changelog.only_added = true
      expect(changelog.is_changelog_format_correct?(filename: filename, placeholder_line: nil)).to be true
      expect(changelog.is_changelog_format_correct?(filename: filename, placeholder_line: nil, only_added: false)).to be false
      allow(changelog.git).to receive(:diff_for_file).and_return(nil)
      expect(changelog.is_changelog_format_correct?(filename: filename)).to be false
      expect(changelog.status_report[:errors].last).to include('Cannot inspect the diff')
    end
  end

  it 'filters Keep a Changelog diagnostics while still requiring its preamble' do
    preamble = File.read(File.expand_path('../keep_a_changelog/fixtures/complete.md', __dir__)).split('## [Unreleased]').first
    source = "#{preamble}## [Unreleased]\nInvalid old text\nInvalid new text\n"
    patch = "@@ -0,0 +#{source.lines.length} @@\n+Invalid new text\n"
    with_changelog(source, patch) do |filename|
      expect(changelog.is_changelog_format_correct?(filename: filename, format: :keep_a_changelog, only_added: true)).to be false
      expect(changelog.status_report[:markdowns].map(&:message)).to eq(["```markdown\nInvalid new text\n```\n"])
    end
  end

  it 'does not suppress global Keep a Changelog failures or missing files' do
    with_changelog("## [Unreleased]\n", '') do |filename|
      expect(changelog.is_changelog_format_correct?(filename: filename, format: :keep_a_changelog, only_added: true)).to be false
      expect(changelog.status_report[:errors].last).to include('missing the version header')
    end
    expect(changelog.is_changelog_format_correct?(filename: 'missing-changelog', only_added: true)).to be false
    expect(changelog.status_report[:errors].last).to include('does not exist')
  end
end
