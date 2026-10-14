require 'spec_helper'

describe Danger::Changelog::ChangelogEntryLine do
  it_behaves_like 'validates as changelog entry line', '* Valid without PR link - [@dblock](https://github.com/dblock).'
  it_behaves_like 'validates as changelog entry line', '* Valid without PR link - [@dblock](https://github.com/dblock).'
  it_behaves_like 'validates as changelog entry line', '* [#1](https://github.com/dblock/danger-changelog/pull/1): Valid with PR link - [@dblock](https://github.com/dblock).'
  it_behaves_like 'validates as changelog entry line', 'Missing star - [@dblock](https://github.com/dblock).'
  it_behaves_like 'validates as changelog entry line', '* [#1](https://github.com/dblock/danger-changelog/pull/1) - Not a colon - [@dblock](https://github.com/dblock).'
  it_behaves_like 'validates as changelog entry line', '* [#1](https://github.com/dblock/danger-changelog/pull/1): No dash [@dblock](https://github.com/dblock).'
  it_behaves_like 'validates as changelog entry line', '* [#1](https://github.com/dblock/danger-changelog/pull/1): No final period - [@dblock](https://github.com/dblock)'
  it_behaves_like 'validates as changelog entry line', '* [#1](https://github.com/dblock/danger-changelog/pull/1): No name.'
  it_behaves_like 'validates as changelog entry line', '* [#1](https://github.com/dblock/danger-changelog/pull/1): No https in github - [@dblock](http://github.com/dblock).'
  it_behaves_like 'validates as changelog entry line', '* [#1](https://github.com/dblock/danger-changelog/pull/1): Extra trailing slash - [@dblock](https://github.com/dblock/).'
  it_behaves_like 'validates as changelog entry line', '# [#1](https://github.com/dblock/danger-changelog/pull/1): Hash instead of star - [@dblock](https://github.com/dblock).'

  it_behaves_like 'does not validate as changelog entry line', 'Missing star, PR and author link.'
  it_behaves_like 'does not validate as changelog entry line', '* '
  it_behaves_like 'does not validate as changelog entry line', '[@dblock](https://github.com/dblock).'
  it_behaves_like 'does not validate as changelog entry line', ' - [@dblock](https://github.com/dblock).'
  it_behaves_like 'does not validate as changelog entry line', '[#1](https://github.com/dblock/danger-changelog/pull/1).'
  it_behaves_like 'does not validate as changelog entry line', '[#1](https://github.com/dblock/danger-changelog/pull/1):  '

  context 'changelog entry line' do
    context 'when without PR link' do
      it_behaves_like 'valid changelog entry line', '* Valid without PR link - [@antondomashnev](https://github.com/antondomashnev).'
    end

    context 'when with PR link' do
      it_behaves_like 'valid changelog entry line', '* [#1](https://github.com/dblock/danger-changelog/pull/1): Valid with PR link - [@dblock](https://github.com/dblock).'
    end

    context 'when missing star' do
      it_behaves_like 'invalid changelog entry line', 'Missing star - [@dblock](https://github.com/dblock).'
    end

    context 'when not a colon' do
      it_behaves_like 'invalid changelog entry line', '* [#1](https://github.com/dblock/danger-changelog/pull/1) - Not a colon - [@dblock](https://github.com/dblock).'
    end

    context 'when no dash' do
      it_behaves_like 'invalid changelog entry line', '* [#1](https://github.com/dblock/danger-changelog/pull/1): No dash [@dblock](https://github.com/dblock).'
    end

    context 'when no final period' do
      it_behaves_like 'invalid changelog entry line', '* [#1](https://github.com/dblock/danger-changelog/pull/1): No final period - [@dblock](https://github.com/dblock)'
    end

    context 'when no name' do
      it_behaves_like 'invalid changelog entry line', '* [#1](https://github.com/dblock/danger-changelog/pull/1): No name.'
    end

    context 'when no https in GitHub' do
      it_behaves_like 'invalid changelog entry line', '* [#1](https://github.com/dblock/danger-changelog/pull/1): No https in github - [@dblock](http://github.com/dblock).'
    end

    context 'when extra trailing slash' do
      it_behaves_like 'invalid changelog entry line', '* [#1](https://github.com/dblock/danger-changelog/pull/1): Extra trailing slash - [@dblock](https://github.com/dblock/).'
    end

    context 'when extra period' do
      it_behaves_like 'invalid changelog entry line', '* [#1](https://github.com/dblock/danger-changelog/pull/1): Extra period. - [@dblock](https://github.com/dblock).'
    end

    context 'when extra colon' do
      it_behaves_like 'invalid changelog entry line', '* [#1](https://github.com/dblock/danger-changelog/pull/1): Extra colon, - [@dblock](https://github.com/dblock).'
    end

    context 'when extra hash' do
      it_behaves_like 'valid changelog entry line', '* [#1](https://github.com/dblock/danger-changelog/pull/1): With # - [@dblock](https://github.com/dblock).'
    end

    context 'when with question mark' do
      it_behaves_like 'valid changelog entry line', '* [#1](https://github.com/dblock/danger-changelog/pull/1): With ? - [@dblock](https://github.com/dblock).'
    end

    context 'when hash instead of star' do
      it_behaves_like 'invalid changelog entry line', '# [#1](https://github.com/dblock/danger-changelog/pull/1): Hash instead of star - [@dblock](https://github.com/dblock).'
    end
  end

  context 'example' do
    let(:github) do
      double(
        Danger::RequestSources::GitHub,
        pr_json: {
          'number' => 123, 'html_url' => 'https://github.com/dblock/danger-changelog/pull/123'
        },
        pr_author: 'dblock',
        pr_title: pr_title
      )
    end

    context 'no transformation required' do
      let(:pr_title) { 'Test' }

      it 'uses title as is' do
        expect(described_class.example(github)).to eq '* [#123](https://github.com/dblock/danger-changelog/pull/123): Test - [@dblock](https://github.com/dblock).'
      end
    end

    context 'with lowercase title' do
      let(:pr_title) { 'test' }

      it 'capitalizes it' do
        expect(described_class.example(github)).to eq '* [#123](https://github.com/dblock/danger-changelog/pull/123): Test - [@dblock](https://github.com/dblock).'
      end
    end

    context 'with a trailing period' do
      let(:pr_title) { 'Test.' }

      it 'removes it' do
        expect(described_class.example(github)).to eq '* [#123](https://github.com/dblock/danger-changelog/pull/123): Test - [@dblock](https://github.com/dblock).'
      end
    end

    context 'with a bot author' do
      let(:pr_title) { 'Update dependencies' }

      %w[github-actions[bot] dependabot[bot]].each do |author|
        it "generates a valid example for #{author}" do
          allow(github).to receive(:pr_author).and_return(author)
          example = described_class.example(github)
          expect(example).to include("[@#{author}](https://github.com/#{author})")
          expect(described_class.new(example).valid?).to be true
        end
      end
    end
  end

  context 'with bot attribution' do
    [
      '[@github-actions[bot]](https://github.com/apps/github-actions)',
      '[@dependabot[bot]](https://github.com/dependabot[bot])',
      '[@renovate[bot]](https://github.com/apps/renovate)'
    ].each do |author_link|
      context author_link do
        [
          "* Update dependencies - #{author_link}.",
          "* [#1](https://github.com/dblock/danger-changelog/pull/1): Update dependencies - #{author_link}."
        ].each do |line|
          it_behaves_like 'validates as changelog entry line', line
          it_behaves_like 'valid changelog entry line', line
        end

        it 'recognizes an author link on its own' do
          expect(described_class.with_author_link?(author_link)).to be true
        end

        ['.', ','].each do |punctuation|
          it "reports an extra #{punctuation} at the end of the description" do
            entry = described_class.new("* Update dependencies#{punctuation} - #{author_link}.\n")
            expect(entry.valid?).to be false
            expect(entry.validation_result.errors)
              .to include('has an extra period or comma at the end of the description')
          end
        end

        it_behaves_like 'invalid changelog entry line', "* Update dependencies - #{author_link}"
        it_behaves_like 'invalid changelog entry line', "* Update dependencies - #{author_link}. \n"
        it_behaves_like 'invalid changelog entry line', "* Update dependencies - #{author_link.sub('https:', 'http:')}."
        it_behaves_like 'invalid changelog entry line', "* Update dependencies - #{author_link.sub('github.com', 'gitlab.com')}."
      end
    end

    %w[github-actions[Bot] github-actions[bot]extra github-actions[bot][bot] github-actions[]].each do |author|
      it "rejects malformed bot suffix in #{author}" do
        link = "[@#{author}](https://github.com/apps/github-actions)"
        expect(described_class.with_author_link?(link)).to be false
        expect(described_class.new("* Update dependencies - #{link}.").valid?).to be false
      end
    end
  end
end
