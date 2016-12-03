require File.expand_path('../spec_helper', __FILE__)

describe Danger::Changelog do
  it 'is a Danger plugin' do
    expect(Danger::DangerChangelog.new(nil)).to be_a Danger::Plugin
  end

  describe 'with Dangerfile' do
    let(:filename) { File.expand_path('../fixtures/changelogs/minimal.md', __FILE__) }
    let(:dangerfile) { testing_dangerfile }
    let(:changelog) do
      dangerfile.changelog.filename = filename
      dangerfile.changelog
    end
    let(:status_report) { changelog.status_report }

    describe 'in a PR' do
      before do
        # typical PR JSON looks like https://raw.githubusercontent.com/danger/danger/bffc246a11dac883d76fc6636319bd6c2acd58a3/spec/fixtures/pr_response.json
        changelog.env.request_source.pr_json = {
          'number' => 123,
          'title' => 'being dangerous',
          'html_url' => 'https://github.com/dblock/danger-changelog/pull/123',
          'user' => {
            'login' => 'dblock'
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
            allow(changelog.git).to receive(:added_files).and_return([])
          end

          it 'complains when no CHANGELOG can be found' do
            expect(subject).to be false
            expect(status_report[:errors]).to eq []
            expect(status_report[:warnings]).to eq ["Unless you're refactoring existing code, please update #{filename}."]
            expect(status_report[:markdowns].map(&:message)).to eq ["Here's an example of a #{filename} entry:\n\n```markdown\n* [#123](https://github.com/dblock/danger-changelog/pull/123): Being dangerous - [@dblock](https://github.com/dblock).\n```\n"]
          end
        end

        context 'with a new CHANGELOG' do
          before do
            allow(changelog.git).to receive(:modified_files).and_return([])
            allow(changelog.git).to receive(:added_files).and_return([filename])
          end

          it 'has no complaints' do
            expect(subject).to be true
            expect(status_report[:errors]).to eq []
            expect(status_report[:warnings]).to eq []
            expect(status_report[:markdowns]).to eq []
          end
        end

        context 'with CHANGELOG changes' do
          before do
            allow(changelog.git).to receive(:modified_files).and_return([filename])
            allow(changelog.git).to receive(:added_files).and_return([])
          end

          it 'has no complaints' do
            expect(subject).to be true
            expect(status_report[:errors]).to eq []
            expect(status_report[:warnings]).to eq []
            expect(status_report[:markdowns]).to eq []
          end
        end
      end

      context 'is_changelog_format_correct?' do
        subject do
          changelog.is_changelog_format_correct?
        end

        context 'without a CHANGELOG file' do
          let(:filename) { 'does-not-exist' }
          it 'complains' do
            expect(subject).to be false
            expect(status_report[:errors]).to eq ['The does-not-exist file does not exist.']
          end
        end

        context 'with CHANGELOG changes' do
          before do
            allow(changelog.git).to receive(:modified_files).and_return([filename])
            allow(changelog.git).to receive(:added_files).and_return([])
          end

          it 'has no complaints' do
            expect(subject).to be true
            expect(status_report[:errors]).to eq []
            expect(status_report[:warnings]).to eq []
            expect(status_report[:markdowns]).to eq []
          end

          context 'missing your contribution here' do
            let(:filename) { File.expand_path('../fixtures/changelogs/missing_your_contribution_here.md', __FILE__) }
            it 'complains' do
              expect(subject).to be false
              expect(status_report[:errors]).to eq ["Please put back the `* Your contribution here.` line into #{filename}."]
              expect(status_report[:warnings]).to eq []
              expect(status_report[:markdowns]).to eq []
            end
          end

          context 'minimal example' do
            let(:filename) { File.expand_path('../fixtures/changelogs/minimal.md', __FILE__) }
            it 'is ok' do
              expect(subject).to be true
              expect(status_report[:errors]).to eq []
              expect(status_report[:warnings]).to eq []
              expect(status_report[:markdowns]).to eq []
            end
          end

          context 'with bad lines' do
            let(:filename) { File.expand_path('../fixtures/changelogs/with_bad_lines.md', __FILE__) }
            it 'complains' do
              expect(subject).to be false
              expect(status_report[:errors]).to eq ["One of the lines below found in #{filename} doesn't match the expected format. Please make it look like the other lines, pay attention to periods and spaces."]
              expect(status_report[:warnings]).to eq []
              expect(status_report[:markdowns].map(&:message)).to eq [
                "```markdown\nMissing star - [@dblock](https://github.com/dblock).\n```\n",
                "```markdown\n* [#1](https://github.com/dblock/danger-changelog/pull/1) - Not a colon - [@dblock](https://github.com/dblock).\n```\n",
                "```markdown\n* [#1](https://github.com/dblock/danger-changelog/pull/1): No final period - [@dblock](https://github.com/dblock)\n```\n",
                "```markdown\n# [#1](https://github.com/dblock/danger-changelog/pull/1): Hash instead of star - [@dblock](https://github.com/dblock).\n```\n",
                "```markdown\n* [#1](https://github.com/dblock/danger-changelog/pull/1): Extra period. - [@dblock](https://github.com/dblock).\n```\n"
              ]
            end
          end
        end
      end
    end
  end
end
