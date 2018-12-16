require File.expand_path('spec_helper', __dir__)

describe Danger::Changelog::ChangelogHeaderLine do
  context 'changelog line' do
    it 'validates as changelog line' do
      expect(described_class.validates_as_changelog_line?('# 1.0.1')).to be true
      expect(described_class.validates_as_changelog_line?('## Version 1.0.1')).to be true
      expect(described_class.validates_as_changelog_line?('### Lollypop')).to be true
      expect(described_class.validates_as_changelog_line?('#### Four hashes is too much')).to be true
      expect(described_class.validates_as_changelog_line?('# 1.0.1 (1/2/3)')).to be true
    end

    it 'doesnt validate as changelog line' do
      expect(described_class.validates_as_changelog_line?('* Star is invalid.')).to be false
      expect(described_class.validates_as_changelog_line?('It requires a hash symbol')).to be false
      expect(described_class.validates_as_changelog_line?('1.1.1')).to be false
      expect(described_class.validates_as_changelog_line?('Version 2.0.1')).to be false
      expect(described_class.validates_as_changelog_line?('#')).to be false
      expect(described_class.validates_as_changelog_line?('## ')).to be false
      expect(described_class.validates_as_changelog_line?('##### I can not validate five')).to be false
    end
  end

  context 'changelog header line' do
    context 'when one hash symbol' do
      subject { Danger::Changelog::ChangelogHeaderLine.new('# 1.0.1') }

      it 'is valid' do
        expect(subject.valid?).to be true
      end
    end

    context 'with a Next date' do
      subject { Danger::Changelog::ChangelogHeaderLine.new('# 1.0.1 (Next)') }

      it 'is valid' do
        expect(subject.valid?).to be true
      end
    end

    context 'with a date in ISO 8601 format' do
      subject { Danger::Changelog::ChangelogHeaderLine.new('# 1.0.1 (2018/1/2)') }

      it 'is valid' do
        expect(subject.valid?).to be true
      end
    end

    context 'with a date not in ISO 8601 format' do
      subject { Danger::Changelog::ChangelogHeaderLine.new('# 1.0.1 (1/2/2018)') }

      it 'is valid' do
        expect(subject.valid?).to be false
      end
    end

    context 'when two hash symbols' do
      subject { Danger::Changelog::ChangelogHeaderLine.new('## Version 1.0.1') }

      it 'is valid' do
        expect(subject.valid?).to be true
      end
    end

    context 'when three hash symbols' do
      subject { Danger::Changelog::ChangelogHeaderLine.new('### Lollypop') }

      it 'is valid' do
        expect(subject.valid?).to be true
      end
    end

    context 'when four hash symbols' do
      subject { Danger::Changelog::ChangelogHeaderLine.new('#### Four hashes is too much') }

      it 'is valid' do
        expect(subject.valid?).to be true
      end
    end

    context 'when no hash symbol' do
      subject { Danger::Changelog::ChangelogHeaderLine.new('* Star is invalid.') }

      it 'is invalid' do
        expect(subject.invalid?).to be true
      end
    end

    context 'when star instead of hash symbol' do
      subject { Danger::Changelog::ChangelogHeaderLine.new('* Star is invalid.') }

      it 'is invalid' do
        expect(subject.invalid?).to be true
      end
    end

    context 'when no hash symbol' do
      subject { Danger::Changelog::ChangelogHeaderLine.new('It requires hash symbol.') }

      it 'is invalid' do
        expect(subject.invalid?).to be true
      end
    end

    context 'when hash symbol without space' do
      subject { Danger::Changelog::ChangelogHeaderLine.new('###Lollypop') }

      it 'is invalid' do
        expect(subject.invalid?).to be true
      end
    end

    context 'when hash symbol without header title' do
      subject { Danger::Changelog::ChangelogHeaderLine.new('### ') }

      it 'is invalid' do
        expect(subject.invalid?).to be true
      end
    end

    context 'when five hash symbols' do
      subject { Danger::Changelog::ChangelogHeaderLine.new('##### Tooooo much') }

      it 'is invalid' do
        expect(subject.invalid?).to be true
      end
    end
  end
end
