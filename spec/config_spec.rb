require File.expand_path('../spec_helper', __FILE__)

describe Danger::Changelog::Config do
  after(:each) do
    described_class.reset
  end

  describe 'configure' do
    describe 'placeholder_line' do
      context 'when without markdown star' do
        before(:each) do
          Danger::Changelog.configure do |config|
            config.placeholder_line = "Nothing yet.\n"
          end
        end

        it 'ads missing star and saves configuration' do
          expect(Danger::Changelog.config.placeholder_line).to eq "* Nothing yet.\n"
        end
      end

      context 'when without trailing newline' do
        before(:each) do
          Danger::Changelog.configure do |config|
            config.placeholder_line = '* Nothing yet.'
          end
        end

        it 'ads missing trailing newline and saves configuration' do
          expect(Danger::Changelog.config.placeholder_line).to eq "* Nothing yet.\n"
        end
      end

      context 'when valid' do
        before(:each) do
          Danger::Changelog.configure do |config|
            config.placeholder_line = "* Nothing yet.\n"
          end
        end

        it 'saves configuration' do
          expect(Danger::Changelog.config.placeholder_line).to eq "* Nothing yet.\n"
        end
      end
    end
  end
end
