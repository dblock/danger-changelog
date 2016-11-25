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
  end
end
