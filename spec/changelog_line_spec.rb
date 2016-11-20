require File.expand_path('../spec_helper', __FILE__)

describe Danger::Changelog::ChangelogLine do
  context 'lines' do
    it 'valid lines' do
      expect(subject.valid?('* Reticluated spline - [@dblock](https://github.com/dblock).')).to be true
      expect(subject.valid?('* [#1](https://github.com/dblock/danger-changelog/pull/1): Reticluated spline - [@dblock](https://github.com/dblock).')).to be true
    end
    it 'invalid lines' do
      expect(subject.valid?('Missing star - [@dblock](https://github.com/dblock).')).to be false
      expect(subject.valid?('* [#1](https://github.com/dblock/danger-changelog/pull/1) - Not a colon - [@dblock](https://github.com/dblock).')).to be false
      expect(subject.valid?('* [#1](https://github.com/dblock/danger-changelog/pull/1): No dash [@dblock](https://github.com/dblock).')).to be false
      expect(subject.valid?('* [#1](https://github.com/dblock/danger-changelog/pull/1): No final period - [@dblock](https://github.com/dblock)')).to be false
      expect(subject.valid?('* [#1](https://github.com/dblock/danger-changelog/pull/1): No name.')).to be false
      expect(subject.valid?('* [#1](https://github.com/dblock/danger-changelog/pull/1): No https in github - [@dblock](http://github.com/dblock).')).to be false
      expect(subject.valid?('* [#1](https://github.com/dblock/danger-changelog/pull/1): Extra trailing slash - [@dblock](https://github.com/dblock/).')).to be false
      expect(subject.valid?('# [#1](https://github.com/dblock/danger-changelog/pull/1): Hash instead of star - [@dblock](https://github.com/dblock).')).to be false
    end
  end
  context 'example' do
    let(:github) do
      double(Danger::RequestSources::GitHub,
             pr_json: { 'number' => 123, 'html_url' => 'https://github.com/dblock/danger-changelog/pull/123' },
             pr_author: 'dblock',
             pr_title: pr_title)
    end
    context 'no transformation required' do
      let(:pr_title) { 'Test' }
      it 'uses title as is' do
        expect(subject.example(github)).to eq '* [#123](https://github.com/dblock/danger-changelog/pull/123): Test - [@dblock](https://github.com/dblock).'
      end
    end
    context 'with lowercase title' do
      let(:pr_title) { 'test' }
      it 'capitalizes it' do
        expect(subject.example(github)).to eq '* [#123](https://github.com/dblock/danger-changelog/pull/123): Test - [@dblock](https://github.com/dblock).'
      end
    end
    context 'with a trailing period' do
      let(:pr_title) { 'Test.' }
      it 'removes it' do
        expect(subject.example(github)).to eq '* [#123](https://github.com/dblock/danger-changelog/pull/123): Test - [@dblock](https://github.com/dblock).'
      end
    end
  end
end
