require 'spec_helper'

describe Danger::Changelog::ChangelogHeaderLine do
  context 'with relaxed versions' do
    ['### 0.1 [2018/1/1]', '### [0.1] [2018/1/1]', '## [0.2] - 2017-06-20', '### 2.0 (Next)', '## 1.2.3.4', '## 2.0-rc.1+build.2'].each do |header|
      it "accepts #{header} only when configured" do
        config = Danger::Changelog.config.with(strict_semver: false)
        expect(described_class.new(header, config: config).valid?).to be true
        expect(described_class.new(header).valid?).to be false
      end
    end

    ['## 01.2', '## 1.', '## 1..2', '## 2.0 (2018-13-01)', '## [2.0)'].each do |header|
      it "still rejects malformed header #{header}" do
        expect(described_class.new(header, config: Danger::Changelog.config.with(strict_semver: false)).valid?).to be false
      end
    end
  end

  it_behaves_like 'validates as changelog header line', '# 1.0.1'
  it_behaves_like 'validates as changelog header line', '## Version 1.0.1'
  it_behaves_like 'validates as changelog header line', '### three hashes'
  it_behaves_like 'validates as changelog header line', '#### Four hashes is too much'
  it_behaves_like 'does not validate as changelog header line', 'something else'

  it_behaves_like 'valid changelog header line', '# 1.0.1'
  it_behaves_like 'valid changelog header line', '### Lollypop'

  it_behaves_like 'invalid changelog header line', '# 1.0.1 (1/2/3)'
  it_behaves_like 'invalid changelog header line', '* Star is invalid.'
  it_behaves_like 'invalid changelog header line', '* Star is invalid.'
  it_behaves_like 'invalid changelog header line', 'It requires a hash symbol'
  it_behaves_like 'invalid changelog header line', '1.1.1'
  it_behaves_like 'invalid changelog header line', 'Version 2.0.1'
  it_behaves_like 'invalid changelog header line', '#'
  it_behaves_like 'invalid changelog header line', '## '
  it_behaves_like 'invalid changelog header line', '##### I can not validate five'

  it_behaves_like 'valid changelog header line', '# 1.0.1 (Next)'

  context 'ISO 8601 format date' do
    it_behaves_like 'valid changelog header line', '# 1.0.1 (2018/1/2)'
  end

  context 'date not in ISO 8601 format' do
    it_behaves_like 'invalid changelog header line', '# 1.0.1 (1/2/2018)'
  end

  context 'two hash symbols' do
    it_behaves_like 'valid changelog header line', '## 1.0.1'
  end

  context 'three hash symbols' do
    it_behaves_like 'valid changelog header line', '### Lollypop'
  end

  context 'four hash symbols' do
    it_behaves_like 'valid changelog header line', '#### Four hashes is too much'
  end

  context 'when no hash symbol' do
    it_behaves_like 'invalid changelog header line', '* Star is invalid.'
  end

  context 'when star instead of hash symbol' do
    it_behaves_like 'invalid changelog header line', '* Star is invalid.'
  end

  context 'when no hash symbol' do
    it_behaves_like 'invalid changelog header line', 'It requires hash symbol.'
  end

  context 'when hash symbol without space' do
    it_behaves_like 'invalid changelog header line', '###Lollypop'
  end

  context 'when hash symbol without header title' do
    it_behaves_like 'invalid changelog header line', '### '
  end

  context 'when five hash symbols' do
    it_behaves_like 'invalid changelog header line', '##### Tooooo much'
  end

  context 'with a string as semver' do
    it_behaves_like 'invalid changelog header line', '# Invalid (Next)'
  end

  context 'with an invalid semver' do
    it_behaves_like 'invalid changelog header line', '# 0.1.'
  end

  context 'with a colon' do
    it_behaves_like 'valid changelog header line', '### Changed:'
  end

  context 'in brackets' do
    it_behaves_like 'valid changelog header line', '### [Unreleased]'
  end

  context 'in parenthesis' do
    it_behaves_like 'valid changelog header line', '### (Unreleased)'
    it_behaves_like 'invalid changelog header line', '### (Unreleased'
    it_behaves_like 'invalid changelog header line', '### Unreleased)'
    it_behaves_like 'invalid changelog header line', '### [Unreleased'
    it_behaves_like 'invalid changelog header line', '### (Unreleased]'
    it_behaves_like 'invalid changelog header line', '### Unreleased]'
  end
end
