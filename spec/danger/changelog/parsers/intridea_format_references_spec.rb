require 'spec_helper'
require 'tempfile'

describe Danger::Changelog::Parsers::IntrideaFormat do
  def parse(markdown)
    Tempfile.create(['changelog-references', '.md']) do |file|
      file.write(markdown)
      file.flush
      config = Danger::Changelog.config.with(placeholder_line: nil)
      result = Danger::Changelog::ChangelogFile.new(file.path, parser: config.parser)
      result.parse
      result
    end
  end

  let(:author_url) { 'https://github.com/dblock' }
  let(:pr_url) { 'https://github.com/dblock/danger-changelog/pull/1' }

  it 'accepts shortcut PR and author references defined after entries' do
    result = parse("* [#1]: Fix issue - [@dblock].\n\n[#1]: #{pr_url}\n[@dblock]: #{author_url}\n")
    expect(result.good?).to be true
  end

  it 'accepts full and collapsed references mixed with inline links' do
    result = parse("* [#1][pr]: Fix issue - [@dblock][].\n* Fix again - [@dblock](#{author_url}).\n\n[pr]: #{pr_url}\n[@dblock]: #{author_url}\n")
    expect(result.good?).to be true
  end

  it 'normalizes reference labels and accepts angle destinations with optional titles' do
    result = parse("* [#1][Pull  Request]: Fix issue - [@dblock][AUTHOR].\n\n[pull request]: <#{pr_url}> \"PR title\"\n[author]: <#{author_url}> 'Author'\n")
    expect(result.good?).to be true
  end

  it 'accepts a destination and title on indented continuation lines' do
    result = parse("* Fix issue - [@dblock].\n\n[@dblock]:\n  <#{author_url}>\n  \"Author\"\n")
    expect(result.good?).to be true
  end

  it 'uses the first duplicate definition' do
    result = parse("* Fix issue - [@dblock].\n\n[@dblock]: #{author_url}\n[@DBLOCK]: https://example.com/dblock\n")
    expect(result.good?).to be true
  end

  it 'reports undefined references using the original entry' do
    entry = "* [#1][missing-pr]: Fix issue - [@dblock].\n"
    result = parse(entry)
    expect(result.bad_lines).to eq([[entry, 'undefined Markdown reference: [missing-pr], undefined Markdown reference: [@dblock]']])
  end

  it 'validates resolved destinations without changing the reported source' do
    entry = "* Fix issue - [@dblock].\n"
    result = parse("#{entry}\n[@dblock]: https://example.com/dblock\n")
    expect(result.bad_lines.first.first).to eq(entry)
    expect(result.bad_lines.first.last).to include('does not include an author link')
  end

  it 'preserves punctuation diagnostics on reference entries' do
    entry = "* [#1] Fix issue - [@dblock].\n"
    result = parse("#{entry}\n[#1]: #{pr_url}\n[@dblock]: #{author_url}\n")
    expect(result.bad_lines).to eq([[entry, 'is missing a colon after the pull request link']])
  end

  it 'does not expand example references inside inline code' do
    result = parse("* Document `[#1][unknown]` syntax - [@dblock](#{author_url}).\n")
    expect(result.good?).to be true
  end

  it 'supports bot attribution with a separately named reference' do
    result = parse("* Update dependencies - [@dependabot[bot]][bot].\n\n[bot]: https://github.com/dependabot[bot]\n")
    expect(result.good?).to be true
  end
end
