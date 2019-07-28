require File.expand_path('spec_helper', __dir__)

describe Danger::Changelog::Config do
  describe 'placeholder_line' do
    context 'when without markdown star' do
      before do
        Danger::Changelog.config.placeholder_line = "Nothing yet.\n"
      end

      it 'ads missing star and saves configuration' do
        expect(Danger::Changelog.config.placeholder_line).to eq "* Nothing yet.\n"
      end
    end

    context 'when without trailing newline' do
      before do
        Danger::Changelog.config.placeholder_line = '* Nothing yet.'
      end

      it 'ads missing trailing newline and saves configuration' do
        expect(Danger::Changelog.config.placeholder_line).to eq "* Nothing yet.\n"
      end
    end

    context 'when valid' do
      before do
        Danger::Changelog.config.placeholder_line = "* Nothing yet.\n"
      end

      it 'saves configuration' do
        expect(Danger::Changelog.config.placeholder_line).to eq "* Nothing yet.\n"
      end
    end
  end
  describe 'config' do
    it 'default' do
      expect(Danger::Changelog.config.format).to eq :intridea
    end
    it 'with an invalid format' do
      expect { Danger::Changelog.config.format = :foobar }.to raise_error ArgumentError, 'Invalid format: foobar'
    end
    it 'with a string' do
      expect { Danger::Changelog.config.format = 'intridea' }.to_not raise_error
    end
    it 'with a symbol' do
      expect { Danger::Changelog.config.format = :intridea }.to_not raise_error
    end
    Danger::Changelog::Parsers::FORMATS.each_pair do |format, parser|
      context format do
        before do
          Danger::Changelog.config.format = format
        end
        it 'sets format' do
          expect(Danger::Changelog.config.format).to eq format
        end
        it 'creates parser' do
          expect(Danger::Changelog.config.parser).to be_a parser
        end
      end
    end
  end
end
