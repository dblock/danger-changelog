require 'spec_helper'
require 'tempfile'

describe Danger::Changelog do
  subject(:changelog) { testing_dangerfile.changelog }

  let(:intridea) { File.expand_path('../intridea/fixtures/customized.md', __dir__) }
  let(:keep_a_changelog) { File.expand_path('../keep_a_changelog/fixtures/complete.md', __dir__) }

  before do
    allow(changelog.git).to receive_messages(modified_files: [intridea, keep_a_changelog], added_files: [])
  end

  %i[intridea keep_a_changelog].each do |format|
    it "applies per-check version rules to #{format} without leaking defaults" do
      source = File.read(keep_a_changelog).sub('## [Unreleased]', '## [2.0]')
      source = "## 2.0 (Next)\n" if format == :intridea
      Tempfile.create(['relaxed-version', '.md']) do |file|
        file.write(source)
        file.flush
        options = { filename: file.path, format: format, placeholder_line: nil }
        expect(changelog.is_changelog_format_correct?(**options, strict_semver: false)).to be true
        expect(changelog.is_changelog_format_correct?(**options)).to be false
      end
    end
  end

  it 'uses per-check placeholders without leaking them to later checks' do
    expect(changelog.check!(filename: intridea, placeholder_line: 'Nothing yet.')).to be true
    expect(changelog.check!(filename: intridea)).to be false
    expect(changelog.placeholder_line).to eq("* Your contribution here.\n")
    expect(changelog.filename).to eq('CHANGELOG.md')
  end

  it 'uses a per-check parser and leaves global defaults unchanged' do
    expect(changelog.check!(filename: keep_a_changelog, format: 'keep_a_changelog')).to be true
    expect(changelog.is_changelog_format_correct?(filename: intridea, placeholder_line: nil)).to be false
    expect(changelog.format).to eq(:intridea)
  end

  it 'uses overrides in individual change and reminder checks' do
    expect(changelog.changelog_changes?(filename: intridea)).to be true
    expect(changelog.changelog_changes?).to be false
    expect(changelog.file_changes?(ignore_files: [/.*/])).to be false
    expect(changelog.have_you_updated_changelog?(ignore_files: [/.*/])).to be true
    expect(changelog.have_you_updated_changelog?(filename: 'CHANGES.md')).to be false
    expect(changelog.status_report[:warnings].last).to include('CHANGES.md')
  end

  it 'applies global defaults and isolates overrides across plugin instances' do
    changelog.filename = intridea
    changelog.placeholder_line = 'Nothing yet.'
    expect(changelog.check!).to be true
    expect(changelog.check!(filename: keep_a_changelog, format: :keep_a_changelog)).to be true
    expect(testing_dangerfile.changelog.is_changelog_format_correct?).to be true
    expect(changelog.filename).to eq(intridea)
  end

  it 'keeps parser configuration stable when globals change after parser creation' do
    parser = described_class.config.with(placeholder_line: 'Nothing yet.').parser
    file = Danger::Changelog::ChangelogFile.new(intridea, parser: parser)
    changelog.placeholder_line = nil
    file.parse
    expect(file.good?).to be true
  end

  it 'uses one snapshot across the reminder and format validation' do
    allow(changelog.git).to receive(:modified_files) do
      changelog.placeholder_line = nil
      [intridea]
    end
    expect(changelog.check!(filename: intridea, placeholder_line: 'Nothing yet.')).to be true
  end

  it 'can disable a placeholder for one check' do
    filename = File.expand_path('../intridea/fixtures/missing_your_contribution_here.md', __dir__)
    expect(changelog.is_changelog_format_correct?(filename: filename, placeholder_line: nil)).to be true
    expect(changelog.is_changelog_format_correct?(filename: filename)).to be false
  end

  it 'supports legacy check with an isolated positional format and keyword overrides' do
    expect(changelog.check(:keep_a_changelog, filename: keep_a_changelog)).to be true
    expect(changelog.format).to eq(:intridea)
  end
end
