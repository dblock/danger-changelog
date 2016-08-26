require File.expand_path('../spec_helper', __FILE__)

module Danger
  describe Danger::DangerChangelog do
    it 'is a Danger plugin' do
      expect(Danger::DangerChangelog.new(nil)).to be_a Danger::Plugin
    end

    describe 'with Dangerfile' do
      let(:dangerfile) { testing_dangerfile }
      let(:changelog) { testing_dangerfile.changelog }
      let(:status_report) { changelog.status_report }

      describe 'in a PR' do
        before do
          # typical PR JSON looks like https://raw.githubusercontent.com/danger/danger/bffc246a11dac883d76fc6636319bd6c2acd58a3/spec/fixtures/pr_response.json
          changelog.env.request_source.pr_json = {
            number: 123,
            title: 'being dangerous',
            html_url: 'https://github.com/dblock/danger-changelog/pull/123',
            user: {
              login: 'dblock'
            }
          }
        end

        context 'have_you_updated_changelog?' do
          subject do
            changelog.have_you_updated_changelog?
          end

          context 'without CHANGELOG changes' do
            before do
              allow(changelog.git).to receive(:modified_files).and_return([])
            end

            it 'complains when no CHANGELOG can be found' do
              expect(subject).to be false
              expect(status_report[:warnings]).to eq ["Unless you're refactoring existing code, please update CHANGELOG.md."]
              expect(status_report[:markdowns]).to eq ["Here's an example of a CHANGELOG.md entry:\n\n```markdown\n* [#123](https://github.com/dblock/danger-changelog/pull/123): being dangerous - [@dblock](https://github.com/dblock).\n```\n"]
            end
          end

          context 'with CHANGELOG changes' do
            before do
              allow(changelog.git).to receive(:modified_files).and_return(['CHANGELOG.md'])
            end

            it 'has no complaints' do
              expect(subject).to be true
              expect(status_report[:warnings]).to eq []
              expect(status_report[:markdowns]).to eq []
            end
          end
        end
      end
    end
  end
end
