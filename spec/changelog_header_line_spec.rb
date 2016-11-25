require File.expand_path('../spec_helper', __FILE__)

describe Danger::Changelog::ChangelogHeaderLine do
  context 'changelog line' do
    it 'validates as changelog line' do
      expect(described_class.validates_as_changelog_line?('# 1.0.1')).to be true
      expect(described_class.validates_as_changelog_line?('## Version 1.0.1')).to be true
      expect(described_class.validates_as_changelog_line?('### Lollypop')).to be true
      expect(described_class.validates_as_changelog_line?('#### Four hashes is too much')).to be true
    end

    it 'doesnt validate as changelog line' do
      expect(described_class.validates_as_changelog_line?('* Star is not valid.')).to be false
      expect(described_class.validates_as_changelog_line?('It requires a hash symbol')).to be false
      expect(described_class.validates_as_changelog_line?('1.1.1')).to be false
      expect(described_class.validates_as_changelog_line?('Version 2.0.1')).to be false
    end
  end
end
