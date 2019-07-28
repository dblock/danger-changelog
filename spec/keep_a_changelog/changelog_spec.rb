require 'spec_helper'

describe Danger::Changelog do
  let(:dangerfile) { testing_dangerfile }
  let(:changelog) { dangerfile.changelog }
  let(:status_report) { changelog.status_report }

  describe 'in a PR' do
    before do
      changelog.env.request_source.pr_json = {
        'number' => 123,
        'title' => 'being dangerous',
        'html_url' => 'https://github.com/dblock/danger-changelog/pull/123',
        'user' => {
          'login' => 'dblock'
        }
      }
    end

    context 'is_changelog_format_correct?' do
      subject do
        changelog.format = :keep_a_changelog
        changelog.filename = filename
        changelog.is_changelog_format_correct?
      end

      context 'with CHANGELOG changes' do
        before do
          allow(changelog.git).to receive(:modified_files).and_return([filename])
          allow(changelog.git).to receive(:added_files).and_return([])
        end

        context 'valid file' do
          let(:filename) { File.expand_path('fixtures/complete.md', __dir__) }
          it 'has no complaints' do
            expect(subject).to be true
            expect(status_report[:errors]).to eq []
            expect(status_report[:warnings]).to eq []
            expect(status_report[:markdowns]).to eq []
          end
        end

        context 'missing a version header' do
          let(:filename) { File.expand_path('fixtures/missing_a_version_header.md', __dir__) }
          it 'complains' do
            expect(subject).to be false
            expect(status_report[:errors]).to eq [
              "One of the lines below found in /Users/dblock/source/danger/danger-changelog/spec/keep_a_changelog/fixtures/missing_a_version_header.md doesn't match the [expected format](https://keepachangelog.com).",
              'The changelog is missing the version header for the Keep A Changelog format. See <https://keepachangelog.com> to see the format of the header'
            ]
            expect(status_report[:warnings]).to eq []
            expect(status_report[:markdowns].map(&:message)).to eq [
              "```markdown\nAll notable changes to this project will be documented in this file.```\n"
            ]
          end
        end
      end
    end
  end
end
