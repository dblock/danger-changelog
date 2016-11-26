require File.expand_path('../spec_helper', __FILE__)

describe Danger::Changelog::ChangelogPlaceholderLine do
  context 'changelog line' do
    it 'validates as changelog line' do
      expect(described_class.validates_as_changelog_line?("* Your contribution here.\n")).to be true
    end

    it 'doesnt validate as changelog line' do
      expect(described_class.validates_as_changelog_line?('* Your contribution here.')).to be false
      expect(described_class.validates_as_changelog_line?("* Your contribution here\n")).to be false
      expect(described_class.validates_as_changelog_line?("* Put your contribution here.\n")).to be false
      expect(described_class.validates_as_changelog_line?("Your contribution here.\n")).to be false
    end

    context 'changelog placeholder line' do
      context 'when exactly expected string' do
        subject { Danger::Changelog::ChangelogPlaceholderLine.new("* Your contribution here.\n") }

        it 'is valid' do
          expect(subject.valid?).to be true
        end
      end

      context 'when without new line' do
        subject { Danger::Changelog::ChangelogPlaceholderLine.new('* Your contribution here.') }

        it 'is invalid' do
          expect(subject.invalid?).to be true
        end
      end

      context 'when no final period' do
        subject { Danger::Changelog::ChangelogPlaceholderLine.new("* Your contribution here\n") }

        it 'is invalid' do
          expect(subject.invalid?).to be true
        end
      end

      context 'when text doesnt match' do
        subject { Danger::Changelog::ChangelogPlaceholderLine.new("* Put your contribution here.\n") }

        it 'is invalid' do
          expect(subject.invalid?).to be true
        end
      end

      context 'when there is not star' do
        subject { Danger::Changelog::ChangelogPlaceholderLine.new("Your contribution here.\n") }

        it 'is invalid' do
          expect(subject.invalid?).to be true
        end
      end
    end
  end
end
