require File.expand_path('spec_helper', __dir__)

describe Danger::Changelog::ChangelogFile do
  let(:filename) { 'CHANGELOG.md' }
  subject do
    Danger::Changelog::ChangelogFile.new(filename)
  end
  context 'minimal example' do
    let(:filename) { File.expand_path('fixtures/changelogs/minimal.md', __dir__) }
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
    let(:filename) { File.expand_path('fixtures/changelogs/missing_your_contribution_here.md', __dir__) }
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
    let(:filename) { File.expand_path('fixtures/changelogs/with_bad_lines.md', __dir__) }
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
  context 'with bad dates' do
    let(:filename) { File.expand_path('fixtures/changelogs/with_bad_dates.md', __dir__) }
    it 'is invalid' do
      expect(subject.bad_lines?).to be true
    end
    it 'reports all bad dates' do
      expect(subject.bad_lines).to eq [
        "### 1.2.3 (1/2/2018)\n",
        "### 1.2.3 (2018/13/1)\n",
        "### 1.2.3 (2018/13)\n",
        "### 1.2.3 (2018/1/1/3)\n"
      ]
    end
  end
  context 'with bad semver' do
    let(:filename) { File.expand_path('fixtures/changelogs/with_bad_semver.md', __dir__) }
    it 'is invalid' do
      expect(subject.bad_lines?).to be true
    end
    it 'reports all bad dates' do
      expect(subject.bad_lines).to eq [
        "### 0 (2018/1/1)\n",
        "### 0. (2018/1/1)\n",
        "### 0.1. (2018/1/1)\n"
      ]
    end
  end
end
