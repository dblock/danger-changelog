require 'spec_helper'

describe Danger::Changelog::IntentCheck do
  let(:config) { Danger::Changelog.config.with(check_intent: true) }

  def failures(entry, **options)
    described_class.new("#{entry}\n", config: config.with(**options)).failures
  end

  it 'accepts every default form on its own' do
    described_class::DEFAULT_WORDS.each do |word|
      expect(failures("* #{word} a feature")).to eq([])
    end
  end

  it 'rejects mixed forms within every default verb family' do
    described_class::WORD_GROUPS.each do |base, *variants|
      variants.each do |variant|
        text = "* #{base} a feature\n* #{variant} another feature\n"
        expect(described_class.new(text, config: config).failures).to eq(
          [[2, "Use '#{base}' consistently instead of '#{variant}' (first used on line 1)."]]
        )
      end
    end
  end

  it 'accepts repeated forms and independent choices across verb families' do
    text = "* Added a feature\n* Fix a bug\n* Added another feature\n"
    expect(described_class.new(text, config: config).failures).to eq([])
  end

  it 'uses the first encountered form even when it is not imperative' do
    text = "* Added a feature\n* Add another feature\n"
    check = described_class.new(text, config: config)
    expected = [[2, "Use 'Added' consistently instead of 'Add' (first used on line 1)."]]
    expect(check.failures).to eq(expected)
    expect(check.failures).to eq(expected)
  end

  it 'checks only additions across multiple hunks, not context or deletions' do
    text = "* Fixed old bug\n* Add a feature\n* Added another feature\n"
    patch = "@@ -1 +1,2 @@\n * Fixed old bug\n+* Add a feature\n@@ -3 +3 @@\n-* Deleted old text\n+* Added another feature\n"
    expect(described_class.new(text, config: config).failures(added_lines: Danger::Changelog::AddedLines.from_patch(patch))).to eq(
      [[3, "Use 'Add' consistently instead of 'Added' (first used on line 2)."]]
    )
  end

  it 'checks descriptions after inline and reference PR links for both list markers' do
    text = "* [#1](https://github.com/org/repo/pull/1): Fixed issue\n- [#1][pr]: Fix another issue\n\n[pr]: https://github.com/org/repo/pull/1\n"
    expect(described_class.new(text, config: config).failures).to eq(
      [[2, "Use 'Fixed' consistently instead of 'Fix' (first used on line 1)."]]
    )
  end

  it 'skips the configured placeholder but reports unknown and lowercase words' do
    expect(failures('* Your contribution here.')).to eq([])
    expect(failures('* Misc changes').first.last).to include('allowed intent word')
    expect(failures('* added feature').first.last).to include('allowed intent word')
  end

  it 'uses a custom dictionary exactly, including Unicode words' do
    expect(failures('* 修复 问题', intent_words: ['修复'])).to eq([])
    expect(failures('* Fix issue', intent_words: ['Resolve']).first.last).to end_with('Resolve.')
    expect(failures('* Added feature', intent_words: ['Add']).first.last).to end_with('Add.')
  end

  it 'still checks consistency when a custom dictionary includes multiple known forms' do
    text = "* Added a feature\n* Add another feature\n"
    expect(described_class.new(text, config: config.with(intent_words: %w[Add Added])).failures).to eq(
      [[2, "Use 'Added' consistently instead of 'Add' (first used on line 1)."]]
    )
  end

  it 'ignores list examples inside fenced code blocks' do
    text = "~~~markdown\n* Add example\n~~~\n* Added feature\n"
    expect(described_class.new(text, config: config).failures).to eq([])
  end
end
