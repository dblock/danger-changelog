require File.expand_path('../spec_helper', __FILE__)

module Danger
  describe Danger::DangerChangelog do
    it 'is a Danger plugin' do
      expect(Danger::DangerChangelog.new(nil)).to be_a Danger::Plugin
    end

    describe 'with Dangerfile' do
      before do
        @dangerfile = testing_dangerfile
        @my_plugin = @dangerfile.my_plugin
      end
    end
  end
end

