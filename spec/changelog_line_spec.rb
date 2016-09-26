require File.expand_path('../spec_helper', __FILE__)

describe Danger::Changelog::ChangelogLine do
  context 'minimal example' do
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
    end
  end
end
