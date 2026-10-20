require 'spec_helper'

describe Danger::Changelog do
  let(:changelog) { testing_dangerfile.changelog }
  let(:gitlab) do
    instance_double(Danger::DangerfileGitLabPlugin, mr_json: mr, mr_title: 'Fix issue', mr_author: 'contributor')
  end
  let(:mr) do
    Struct.new(:iid, :web_url, :author).new(
      123, 'https://gitlab.com/group/subgroup/project/-/merge_requests/123',
      Struct.new(:web_url).new('https://gitlab.com/contributor')
    )
  end

  before do
    allow(changelog).to receive_messages(github_plugin: nil, gitlab_plugin: gitlab)
    allow(changelog.git).to receive_messages(modified_files: ['lib/example.rb'], added_files: [])
    allow(ENV).to receive(:fetch).with('GITHUB_EVENT_PATH', nil).and_return(nil)
  end

  it 'generates a valid GitLab suggestion without a GitHub plugin' do
    expect(changelog.have_you_updated_changelog?).to be false
    report = changelog.status_report[:markdowns].first.message
    expect(report).to include("[#123](#{mr.web_url}): Fix issue - [@contributor](https://gitlab.com/contributor).")
    entry = report.lines.find { |line| line.start_with?('* ') }
    expect(described_class::ChangelogEntryLine.new(entry).valid?).to be true
  end

  it 'still gives a local example when neither provider is available' do
    allow(changelog).to receive(:gitlab_plugin).and_return(nil)
    expect(changelog.have_you_updated_changelog?).to be false
    expect(changelog.status_report[:markdowns].first.message).to include('https://github.com/org/repo/pull/123')
  end
end
