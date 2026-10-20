require 'spec_helper'
require 'tempfile'

describe Danger::Changelog do
  let(:changelog) { testing_dangerfile.changelog }

  %i[intridea keep_a_changelog].each do |format|
    it "enforces opt-in intent through check! for #{format} without leaking overrides" do
      Tempfile.create(['intent', '.md']) do |file|
        source = format == :intridea ? "## 1.0.0 (Next)\n" : File.read(File.expand_path('../keep_a_changelog/fixtures/complete.md', __dir__))
        entries = "* Fixed bug - [@dblock](https://github.com/dblock).\n* Fix another bug - [@dblock](https://github.com/dblock).\n"
        file.write("#{source}\n#{entries}")
        file.flush
        allow(changelog.git).to receive_messages(modified_files: [file.path], added_files: [], diff_for_file: Struct.new(:patch).new("@@ -0,0 +#{File.readlines(file.path).length - 1},2 @@\n#{entries.lines.map { |line| "+#{line}" }.join}"))
        options = { filename: file.path, format: format, placeholder_line: nil, unreleased_heading: nil, only_added: true }
        expect(changelog.check!(**options)).to be true
        expect(changelog.check!(**options, check_intent: true)).to be false
        expect(changelog.status_report[:errors].last).to include("Use 'Fixed' consistently instead of 'Fix'")
        expect(changelog.check_intent).to be false
      end
    end
  end

  it 'reports unavailable diffs instead of silently skipping an enabled check' do
    allow(changelog.git).to receive_messages(modified_files: ['CHANGELOG.md'], added_files: [], diff_for_file: nil)
    changelog.check_intent = true
    expect(changelog.intent_correct?(only_added: true)).to be false
    expect(changelog.status_report[:errors]).to include('Cannot inspect the diff for CHANGELOG.md.')
  end

  context 'with historical entries using a different form' do
    let(:file) { Tempfile.new(['intent-scope', '.md']) }

    around do |example|
      file.write("* Add old feature\n* Added new feature\n")
      file.flush
      example.run
    ensure
      file.close!
    end

    before do
      changelog.filename = file.path
      changelog.check_intent = true
      diff = Struct.new(:patch).new("@@ -1 +1,2 @@\n * Add old feature\n+* Added new feature\n")
      allow(changelog.git).to receive_messages(modified_files: [file.path], added_files: [], diff_for_file: diff)
    end

    it 'compares historical entries by default without requiring a diff' do
      expect(changelog.intent_correct?).to be false
      expect(changelog.git).not_to have_received(:diff_for_file)
      expect(changelog.status_report[:errors].last).to include("Use 'Add' consistently instead of 'Added'")
    end

    it 'limits comparison to added entries with a per-call override' do
      expect(changelog.intent_correct?(only_added: true)).to be true
      expect(changelog.only_added).to be false
    end

    it 'supports global scope and a full-file per-call override' do
      changelog.only_added = true
      expect(changelog.intent_correct?).to be true
      expect(changelog.intent_correct?(only_added: false)).to be false
      expect(changelog.only_added).to be true
    end

    it 'checks unchanged history in full-file mode but selects nothing in added-only mode' do
      allow(changelog.git).to receive(:modified_files).and_return([])
      expect(changelog.intent_correct?).to be false
      expect(changelog.intent_correct?(only_added: true)).to be true
    end
  end

  it 'reports missing files even in added-only mode' do
    expect(changelog.intent_correct?(filename: 'missing-changelog.md', check_intent: true, only_added: true)).to be false
    expect(changelog.status_report[:errors]).to include('The missing-changelog.md file does not exist.')
  end
end
