require File.expand_path('../spec_helper', __FILE__)

describe Danger::Changelog::ChangelogLineParser do
  context 'parse' do
    context 'changelog entry line' do
      context 'when valid' do
        let(:line) { '* [#123](https://github.com/dblock/danger-changelog/pull/123): Test - [@dblock](https://github.com/dblock).' }
        it 'returns ChangelogEntryLine' do
          expect(described_class.parse(line)).to be_a(Danger::Changelog::ChangelogEntryLine)
        end
      end

      context 'when invalid' do
        it 'returns ChangelogEntryLine' do
          expect(described_class.parse('Missing star - [@dblock](https://github.com/dblock).')).to be_a(Danger::Changelog::ChangelogEntryLine)
          expect(described_class.parse('* [#1](https://github.com/dblock/danger-changelog/pull/1) - Not a colon - [@dblock](https://github.com/dblock).')).to be_a(Danger::Changelog::ChangelogEntryLine)
          expect(described_class.parse('* [#1](https://github.com/dblock/danger-changelog/pull/1): No dash [@dblock](https://github.com/dblock).')).to be_a(Danger::Changelog::ChangelogEntryLine)
          expect(described_class.parse('* [#1](https://github.com/dblock/danger-changelog/pull/1): No final period - [@dblock](https://github.com/dblock)')).to be_a(Danger::Changelog::ChangelogEntryLine)
          expect(described_class.parse('* [#1](https://github.com/dblock/danger-changelog/pull/1): No name.')).to be_a(Danger::Changelog::ChangelogEntryLine)
          expect(described_class.parse('* [#1](https://github.com/dblock/danger-changelog/pull/1): No https in github - [@dblock](http://github.com/dblock).')).to be_a(Danger::Changelog::ChangelogEntryLine)
          expect(described_class.parse('* [#1](https://github.com/dblock/danger-changelog/pull/1): Extra trailing slash - [@dblock](https://github.com/dblock/).')).to be_a(Danger::Changelog::ChangelogEntryLine)
          expect(described_class.parse('# [#1](https://github.com/dblock/danger-changelog/pull/1): Hash instead of star - [@dblock](https://github.com/dblock).')).to be_a(Danger::Changelog::ChangelogEntryLine)
        end
      end
    end

    context 'changelog your contribution here line' do
      let(:configuration) do
        mocked_configuration = Danger::Changelog::PluginConfiguration.new
        allow(mocked_configuration).to receive(:placeholder_line) { "* Nothing yet.\n" }
        return mocked_configuration
      end

      context 'when line equals to placeholder_line from configuration' do
        it 'returns ChangelogPlaceholderLine' do
          expect(described_class.parse(configuration.placeholder_line, configuration)).to be_a(Danger::Changelog::ChangelogPlaceholderLine)
        end
      end

      context 'when line doesnt equal to placeholder_line from configuration' do
        let(:line) { "* Release is empty so far.\n" }
        it 'returns ChangelogPlaceholderLine' do
          expect(described_class.parse(line, configuration)).to_not be_a(Danger::Changelog::ChangelogPlaceholderLine)
        end
      end
    end

    context 'changelog header line' do
      context 'when one hash' do
        let(:line) { '# Version 1.1.1' }
        it 'returns ChangelogHeaderLine' do
          expect(described_class.parse(line)).to be_a(Danger::Changelog::ChangelogHeaderLine)
        end
      end

      context 'when two hashes' do
        let(:line) { '## Version 1.1.1' }
        it 'returns ChangelogHeaderLine' do
          expect(described_class.parse(line)).to be_a(Danger::Changelog::ChangelogHeaderLine)
        end
      end

      context 'when three hashes' do
        let(:line) { '### Version 1.1.1' }
        it 'returns ChangelogHeaderLine' do
          expect(described_class.parse(line)).to be_a(Danger::Changelog::ChangelogHeaderLine)
        end
      end
    end
  end
end
