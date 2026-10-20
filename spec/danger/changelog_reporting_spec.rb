require 'spec_helper'
require 'tempfile'
require 'kramdown'
require 'kramdown-parser-gfm'

describe Danger::Changelog do
  let(:changelog) { testing_dangerfile.changelog }
  let(:preamble) do
    File.read(File.expand_path('../keep_a_changelog/fixtures/complete.md', __dir__)).split('## [Unreleased]').first
  end

  it 'renders consecutive invalid lines in separate code blocks without visible fence markers' do
    Tempfile.create(['changelog-report', '.md']) do |file|
      file.write("#{preamble}## [Unreleased]\n\nInvalid first line\nInvalid second line\nText with ``` fences\n")
      file.flush
      expect(changelog.is_changelog_format_correct?(filename: file.path, format: :keep_a_changelog)).to be false
      report = changelog.status_report[:markdowns].map(&:message).join("\n")
      html = Kramdown::Document.new(report, input: 'GFM').to_html
      expect(html.scan('<pre>').length).to eq(3)
      expect(html).not_to include('```markdown')
      expect(html).to include('Text with ``` fences')
    end
  end
end
