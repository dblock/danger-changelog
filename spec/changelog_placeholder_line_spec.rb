require File.expand_path('../spec_helper', __FILE__)

describe Danger::Changelog::ChangelogPlaceholderLine do
  before do
    Danger::Changelog.configure do |config|
      config.placeholder_line = "* Nothing yet here.\n"
    end
  end

  describe 'validates_as_changelog_line?' do
    context 'when line is equal to placeholder_line from config' do
      it 'validates as changelog line' do
        expect(described_class.validates_as_changelog_line?("* Nothing yet here.\n")).to be true
      end
    end

    context 'when line is not equal to placeholder_line from config' do
      it 'validates as changelog line' do
        expect(described_class.validates_as_changelog_line?("* Put your contribution here.\n")).to be false
      end
    end
  end

  describe 'valid?' do
    context 'when is equal to config placeholder line' do
      subject { Danger::Changelog::ChangelogPlaceholderLine.new("* Nothing yet here.\n") }

      it 'is valid' do
        expect(subject.valid?).to be true
      end
    end

    context 'when is not equal to config placeholder line' do
      subject { Danger::Changelog::ChangelogPlaceholderLine.new("* Your change here.\n") }

      it 'is not valid' do
        expect(subject.valid?).to be false
      end
    end
  end
end
