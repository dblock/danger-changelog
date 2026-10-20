require 'spec_helper'

describe Danger::DangerChangelog do
  subject do
    described_class.new(nil)
  end

  it 'is a Danger plugin' do
    expect(subject).to be_a Danger::Plugin
  end

  it 'delegates every declared global option' do
    Danger::Changelog::Config::DEFAULTS.each do |name, value|
      subject.public_send("#{name}=", value)
      expect(subject.public_send(name)).to eq(value)
    end
  end
end
