require File.expand_path('spec_helper', __dir__)

describe Danger::Changelog::ChangelogEntryLine do
  context 'changelog line' do
    it 'validates as changelog line' do
      expect(described_class.validates_as_changelog_line?('* Valid without PR link - [@dblock](https://github.com/dblock).')).to be true
      expect(described_class.validates_as_changelog_line?('* [#1](https://github.com/dblock/danger-changelog/pull/1): Valid with PR link - [@dblock](https://github.com/dblock).')).to be true
      expect(described_class.validates_as_changelog_line?('Missing star - [@dblock](https://github.com/dblock).')).to be true
      expect(described_class.validates_as_changelog_line?('* [#1](https://github.com/dblock/danger-changelog/pull/1) - Not a colon - [@dblock](https://github.com/dblock).')).to be true
      expect(described_class.validates_as_changelog_line?('* [#1](https://github.com/dblock/danger-changelog/pull/1): No dash [@dblock](https://github.com/dblock).')).to be true
      expect(described_class.validates_as_changelog_line?('* [#1](https://github.com/dblock/danger-changelog/pull/1): No final period - [@dblock](https://github.com/dblock)')).to be true
      expect(described_class.validates_as_changelog_line?('* [#1](https://github.com/dblock/danger-changelog/pull/1): No name.')).to be true
      expect(described_class.validates_as_changelog_line?('* [#1](https://github.com/dblock/danger-changelog/pull/1): No https in github - [@dblock](http://github.com/dblock).')).to be true
      expect(described_class.validates_as_changelog_line?('* [#1](https://github.com/dblock/danger-changelog/pull/1): Extra trailing slash - [@dblock](https://github.com/dblock/).')).to be true
      expect(described_class.validates_as_changelog_line?('# [#1](https://github.com/dblock/danger-changelog/pull/1): Hash instead of star - [@dblock](https://github.com/dblock).')).to be true
    end

    it 'doesnt validate as changelog line' do
      expect(described_class.validates_as_changelog_line?('Missing star, PR and author link.')).to be false
      expect(described_class.validates_as_changelog_line?('* ')).to be false
      expect(described_class.validates_as_changelog_line?('[@dblock](https://github.com/dblock).')).to be false
      expect(described_class.validates_as_changelog_line?(' - [@dblock](https://github.com/dblock).')).to be false
      expect(described_class.validates_as_changelog_line?('[#1](https://github.com/dblock/danger-changelog/pull/1).')).to be false
      expect(described_class.validates_as_changelog_line?('[#1](https://github.com/dblock/danger-changelog/pull/1):  ')).to be false
    end
  end

  context 'changelog entry line' do
    context 'when without PR link' do
      subject { Danger::Changelog::ChangelogEntryLine.new('* Valid without PR link - [@antondomashnev](https://github.com/antondomashnev).') }

      it 'is valid' do
        expect(subject.valid?).to be true
      end
    end

    context 'when with PR link' do
      subject { Danger::Changelog::ChangelogEntryLine.new('* [#1](https://github.com/dblock/danger-changelog/pull/1): Valid with PR link - [@dblock](https://github.com/dblock).') }

      it 'is valid' do
        expect(subject.valid?).to be true
      end
    end

    context 'when missing star' do
      subject { Danger::Changelog::ChangelogEntryLine.new('Missing star - [@dblock](https://github.com/dblock).') }

      it 'is invalid' do
        expect(subject.invalid?).to be true
      end
    end

    context 'when not a colon' do
      subject { Danger::Changelog::ChangelogEntryLine.new('* [#1](https://github.com/dblock/danger-changelog/pull/1) - Not a colon - [@dblock](https://github.com/dblock).') }

      it 'is invalid' do
        expect(subject.invalid?).to be true
      end
    end

    context 'when no dash' do
      subject { Danger::Changelog::ChangelogEntryLine.new('* [#1](https://github.com/dblock/danger-changelog/pull/1): No dash [@dblock](https://github.com/dblock).') }

      it 'is invalid' do
        expect(subject.invalid?).to be true
      end
    end

    context 'when no final period' do
      subject { Danger::Changelog::ChangelogEntryLine.new('* [#1](https://github.com/dblock/danger-changelog/pull/1): No final period - [@dblock](https://github.com/dblock)') }

      it 'is invalid' do
        expect(subject.invalid?).to be true
      end
    end

    context 'when no name' do
      subject { Danger::Changelog::ChangelogEntryLine.new('* [#1](https://github.com/dblock/danger-changelog/pull/1): No name.') }

      it 'is invalid' do
        expect(subject.invalid?).to be true
      end
    end

    context 'when no https in GitHub' do
      subject { Danger::Changelog::ChangelogEntryLine.new('* [#1](https://github.com/dblock/danger-changelog/pull/1): No https in github - [@dblock](http://github.com/dblock).') }

      it 'is invalid' do
        expect(subject.invalid?).to be true
      end
    end

    context 'when extra trailing slash' do
      subject { Danger::Changelog::ChangelogEntryLine.new('* [#1](https://github.com/dblock/danger-changelog/pull/1): Extra trailing slash - [@dblock](https://github.com/dblock/).') }

      it 'is invalid' do
        expect(subject.invalid?).to be true
      end
    end

    context 'when extra period' do
      subject { Danger::Changelog::ChangelogEntryLine.new('* [#1](https://github.com/dblock/danger-changelog/pull/1): Extra period. - [@dblock](https://github.com/dblock).') }

      it 'is invalid' do
        expect(subject.invalid?).to be true
      end
    end

    context 'when extra colon' do
      subject { Danger::Changelog::ChangelogEntryLine.new('* [#1](https://github.com/dblock/danger-changelog/pull/1): Extra colon, - [@dblock](https://github.com/dblock).') }

      it 'is invalid' do
        expect(subject.invalid?).to be true
      end
    end

    context 'when extra hash' do
      subject { Danger::Changelog::ChangelogEntryLine.new('* [#1](https://github.com/dblock/danger-changelog/pull/1): With # - [@dblock](https://github.com/dblock).') }

      it 'is valid' do
        expect(subject.valid?).to be true
      end
    end

    context 'when with question mark' do
      subject { Danger::Changelog::ChangelogEntryLine.new('* [#1](https://github.com/dblock/danger-changelog/pull/1): With ? - [@dblock](https://github.com/dblock).') }

      it 'is valid' do
        expect(subject.valid?).to be true
      end
    end

    context 'when hash instead of star' do
      subject { Danger::Changelog::ChangelogEntryLine.new('# [#1](https://github.com/dblock/danger-changelog/pull/1): Hash instead of star - [@dblock](https://github.com/dblock).') }

      it 'is invalid' do
        expect(subject.invalid?).to be true
      end
    end
  end

  context 'example' do
    let(:github) do
      double(Danger::RequestSources::GitHub,
             pr_json: { 'number' => 123, 'html_url' => 'https://github.com/dblock/danger-changelog/pull/123' },
             pr_author: 'dblock',
             pr_title: pr_title)
    end
    context 'no transformation required' do
      let(:pr_title) { 'Test' }
      it 'uses title as is' do
        expect(described_class.example(github)).to eq '* [#123](https://github.com/dblock/danger-changelog/pull/123): Test - [@dblock](https://github.com/dblock).'
      end
    end
    context 'with lowercase title' do
      let(:pr_title) { 'test' }
      it 'capitalizes it' do
        expect(described_class.example(github)).to eq '* [#123](https://github.com/dblock/danger-changelog/pull/123): Test - [@dblock](https://github.com/dblock).'
      end
    end
    context 'with a trailing period' do
      let(:pr_title) { 'Test.' }
      it 'removes it' do
        expect(described_class.example(github)).to eq '* [#123](https://github.com/dblock/danger-changelog/pull/123): Test - [@dblock](https://github.com/dblock).'
      end
    end
  end
end
