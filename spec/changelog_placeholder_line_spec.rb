require File.expand_path('../spec_helper', __FILE__)

describe Danger::Changelog::ChangelogPlaceholderLine do
  context 'changelog line' do
    let(:configuration) do
      mocked_configuration = Danger::Changelog::PluginConfiguration.new
      allow(mocked_configuration).to receive(:placeholder_line) { "* Nothing yet.\n" }
      return mocked_configuration
    end

    context 'when line equal to placeholder_line from configuration' do
      it 'validates as changelog line' do
        expect(described_class.validates_as_changelog_line?(configuration.placeholder_line, configuration)).to be true
      end
    end

    context 'when line equal to placeholder_line from configuration' do
      it 'doesnt validate as changelog line' do
        expect(described_class.validates_as_changelog_line?('* Your contribution here.', configuration)).to be false
      end
    end

    context 'changelog placeholder line' do
      context 'when equal to configuration placeholder_line' do
        subject { Danger::Changelog::ChangelogPlaceholderLine.new(configuration.placeholder_line, configuration) }

        it 'is valid' do
          expect(subject.valid?).to be true
        end
      end

      context 'when doesnt equal to configuration placeholder_line' do
        subject { Danger::Changelog::ChangelogPlaceholderLine.new('* Your contribution here.', configuration) }

        it 'is invalid' do
          expect(subject.invalid?).to be true
        end
      end
    end
  end
end
