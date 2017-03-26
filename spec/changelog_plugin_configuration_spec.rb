require File.expand_path('../spec_helper', __FILE__)

describe Danger::Changelog::PluginConfiguration do
  describe 'default' do
    subject { Danger::Changelog::PluginConfiguration.default }

    it 'returns default configuration' do
      expect(subject.placeholder_line).to eq "* Your contribution here.\n"
    end
  end

  describe 'placeholder_line' do
    context 'when custom provided in options' do
      context 'when has valid prefix and suffix' do
        let(:placeholder_line) { "* Nothing yet.\n" }
        subject { Danger::Changelog::PluginConfiguration.new(placeholder_line: placeholder_line) }

        it 'uses it as a placeholder line' do
          expect(subject.placeholder_line).to eq placeholder_line
        end
      end

      context 'when without markdown list item prefix' do
        let(:placeholder_line) { "Nothing yet.\n" }
        subject { Danger::Changelog::PluginConfiguration.new(placeholder_line: placeholder_line) }

        it 'appends markdown prefix' do
          expect(subject.placeholder_line).to eq "* Nothing yet.\n"
        end
      end

      context 'when without trailing new line' do
        let(:placeholder_line) { "* Nothing yet." }
        subject { Danger::Changelog::PluginConfiguration.new(placeholder_line: placeholder_line) }

        it 'appends trailing newline' do
          expect(subject.placeholder_line).to eq "* Nothing yet.\n"
        end
      end
    end

    context 'when custom is not provided in options' do
      subject { Danger::Changelog::PluginConfiguration.new }

      it 'sets default' do
        expect(subject.placeholder_line).to eq "* Your contribution here.\n"
      end
    end
  end
end
