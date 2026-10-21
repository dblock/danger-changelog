require 'spec_helper'
require 'tempfile'

describe Danger::Changelog do
  subject(:changelog) { testing_dangerfile.changelog }

  let(:intridea) { File.expand_path('../intridea/fixtures/customized.md', __dir__) }
  let(:keep_a_changelog) { File.expand_path('../keep_a_changelog/fixtures/complete.md', __dir__) }

  before do
    allow(changelog.git).to receive_messages(modified_files: [intridea, keep_a_changelog], added_files: [], diff_for_file: Struct.new(:patch).new(''))
  end

  %i[intridea keep_a_changelog].each do |format|
    it "enforces exact unreleased labels for #{format} through global and per-check options" do
      source = format == :intridea ? "## 0.4.0 (next)\n" : File.read(keep_a_changelog)
      Tempfile.create(['unreleased-labels', '.md']) do |file|
        file.write(source)
        file.flush
        options = { filename: file.path, format: format, placeholder_line: nil }
        changelog.unreleased_labels = ['Next']
        expect(changelog.is_changelog_format_correct?(**options)).to be false
        expect(changelog.is_changelog_format_correct?(**options, unreleased_labels: %w[next Unreleased])).to be true
        expect(changelog.is_changelog_format_correct?(**options, unreleased_labels: nil)).to be true
        expect(changelog.unreleased_labels).to eq(['Next'])
      end
    end

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

  it 'checks release sections by default and permits explicit opt-out when diff data is unavailable' do
    allow(changelog.git).to receive(:diff_for_file).with(intridea).and_return(nil)
    expect(changelog.entries_in_unreleased_section?(filename: intridea)).to be false
    expect(changelog.entries_in_unreleased_section?(filename: intridea, unreleased_heading: nil)).to be true
    expect(changelog.status_report[:errors]).to include("Cannot inspect the diff for #{intridea}.")
  end

  it 'checks added entries through check! without changing defaults' do
    Tempfile.create(['release-section', '.md']) do |file|
      file.write("## 0.10.0 (Next)\n* Your contribution here.\n## 0.9.0\n* Historical - [@dblock](https://github.com/dblock).\n")
      file.flush
      diff = Struct.new(:patch).new("@@ -3 +3,2 @@\n ## 0.9.0\n+* Historical - [@dblock](https://github.com/dblock).\n")
      allow(changelog.git).to receive_messages(modified_files: [file.path], diff_for_file: diff)
      expect(changelog.check!(filename: file.path)).to be false
      expect(changelog.check!(filename: file.path, unreleased_heading: nil)).to be true
    end
  end

  { intridea: '## 0.10.0 (next)', keep_a_changelog: '## [unreleased]' }.each do |format, heading|
    it "accepts added entries under the default #{format} heading" do
      Tempfile.create(['release-section', '.md']) do |file|
        file.write("#{heading}\n### Fixed\n* New change\n")
        file.flush
        diff = Struct.new(:patch).new("@@ -1,2 +1,3 @@\n #{heading}\n ### Fixed\n+* New change\n")
        allow(changelog.git).to receive_messages(modified_files: [], added_files: [file.path], diff_for_file: diff)
        expect(changelog.entries_in_unreleased_section?(filename: file.path, format: format)).to be true
      end
    end
  end

  it 'supports global opt-out and a per-check custom heading' do
    changelog.unreleased_heading = nil
    diff = Struct.new(:patch).new("@@ -1 +1,3 @@\n ### Changelog\n+\n+* Nothing yet.\n")
    allow(changelog.git).to receive(:diff_for_file).and_return(diff)
    expect(changelog.entries_in_unreleased_section?(filename: intridea)).to be true
    expect(changelog.entries_in_unreleased_section?(filename: intridea, unreleased_heading: /^### Changelog$/)).to be true
    expect(changelog.unreleased_heading).to be_nil
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
