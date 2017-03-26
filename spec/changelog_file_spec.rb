require File.expand_path('../spec_helper', __FILE__)

describe Danger::Changelog::ChangelogFile do
  let(:filename) { 'CHANGELOG.md' }
  context 'when custom configuration' do
    let(:configuration) {
      mocked_configuration = Danger::Changelog::PluginConfiguration.new()
      allow(mocked_configuration).to receive(:placeholder_line) { "* Nothing yet.\n" }
      return mocked_configuration
    }
    subject do
      Danger::Changelog::ChangelogFile.new(filename, configuration)
    end
    context 'custom your contribution example' do
      let(:filename) { File.expand_path('../fixtures/changelogs/custom_your_contribution_here.md', __FILE__) }
      it 'exists?' do
        expect(subject.exists?).to be true
      end
      it 'bad_lines?' do
        expect(subject.bad_lines).to eq []
        expect(subject.bad_lines?).to be false
      end
      it 'is valid' do
        expect(subject.bad_lines?).to be false
      end
      it 'has your contribution here' do
        expect(subject.your_contribution_here?).to be true
      end
    end
    context 'minimal example' do
      let(:filename) { File.expand_path('../fixtures/changelogs/minimal.md', __FILE__) }
      it 'exists?' do
        expect(subject.exists?).to be true
      end
      it 'bad_lines?' do
        expect(subject.bad_lines).to eq ["* Your contribution here.\n"]
        expect(subject.bad_lines?).to be true
      end
      it 'is not valid' do
        expect(subject.bad_lines?).to be true
      end
      it 'doesnt have your contribution here' do
        expect(subject.your_contribution_here?).to be false
      end
    end
  end
  context 'when default configuration' do
    subject do
      Danger::Changelog::ChangelogFile.new(filename)
    end
    context 'custom your contribution example' do
      let(:filename) { File.expand_path('../fixtures/changelogs/custom_your_contribution_here.md', __FILE__) }
      it 'exists?' do
        expect(subject.exists?).to be true
      end
      it 'bad_lines?' do
        expect(subject.bad_lines).to eq ["* Nothing yet.\n"]
        expect(subject.bad_lines?).to be true
      end
      it 'is not valid' do
        expect(subject.bad_lines?).to be true
      end
      it 'has your contribution here' do
        expect(subject.your_contribution_here?).to be false
      end
    end
    context 'minimal example' do
      let(:filename) { File.expand_path('../fixtures/changelogs/minimal.md', __FILE__) }
      it 'exists?' do
        expect(subject.exists?).to be true
      end
      it 'bad_lines?' do
        expect(subject.bad_lines).to eq []
        expect(subject.bad_lines?).to be false
      end
      it 'is valid' do
        expect(subject.bad_lines?).to be false
      end
      it 'has your contribution here' do
        expect(subject.your_contribution_here?).to be true
      end
    end
    context 'missing your contribution here' do
      let(:filename) { File.expand_path('../fixtures/changelogs/missing_your_contribution_here.md', __FILE__) }
      it 'is valid' do
        expect(subject.bad_lines?).to be false
      end
      it 'is missing your contribution here' do
        expect(subject.your_contribution_here?).to be false
      end
    end
    context 'does not exist' do
      let(:filename) { 'whatever.md' }
      it 'exists?' do
        expect(subject.exists?).to be false
      end
      it 'bad_lines?' do
        expect(subject.bad_lines).to be nil
        expect(subject.bad_lines?).to be false
      end
    end
    context 'with bad lines' do
      let(:filename) { File.expand_path('../fixtures/changelogs/with_bad_lines.md', __FILE__) }
      it 'is invalid' do
        expect(subject.bad_lines?).to be true
      end
      it 'reports all bad lines' do
        expect(subject.bad_lines).to eq [
          "Missing star - [@dblock](https://github.com/dblock).\n",
          "* [#1](https://github.com/dblock/danger-changelog/pull/1) - Not a colon - [@dblock](https://github.com/dblock).\n",
          "* [#1](https://github.com/dblock/danger-changelog/pull/1): No final period - [@dblock](https://github.com/dblock)\n",
          "# [#1](https://github.com/dblock/danger-changelog/pull/1): Hash instead of star - [@dblock](https://github.com/dblock).\n",
          "* [#1](https://github.com/dblock/danger-changelog/pull/1): Extra period. - [@dblock](https://github.com/dblock).\n"
        ]
      end
      it 'has your contribution here' do
        expect(subject.your_contribution_here?).to be true
      end
    end
  end
end
