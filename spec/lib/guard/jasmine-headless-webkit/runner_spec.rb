require 'spec_helper'
require 'guard/jasmine-headless-webkit/runner'
require 'fakefs/spec_helpers'

describe Guard::JasmineHeadlessWebkitRunner do
  describe '.notify' do
    include FakeFS::SpecHelpers

    let(:file) { 'temp.txt' }

    before do
      File.open(file, 'w') { |fh| fh.print data }
    end

    context 'system run not interrupted' do
      let(:data) { '1/0/F/5' }

      it 'should notify with the right information' do
        Guard::Notifier.expects(:notify).with("1 test, 0 failures, 5 secs.", { :title => 'Jasmine results', :image => :success })

        Guard::JasmineHeadlessWebkitRunner.notify(file)
      end
    end

    context 'system run interrupted' do
      let(:data) { '' }

      it 'should notify failure' do
        Guard::Notifier.expects(:notify).with("Spec runner interrupted!", { :title => 'Jasmine results', :image => :failed })

        Guard::JasmineHeadlessWebkitRunner.notify(file)
      end
    end
  end
end
