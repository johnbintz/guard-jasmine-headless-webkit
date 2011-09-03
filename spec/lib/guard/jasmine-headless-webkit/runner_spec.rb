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
      let(:data) { 'TOTAL||1||0||5||F' }

      it 'should notify with the right information' do
        Guard::Notifier.expects(:notify).with("1 test, 0 failures, 5.0 secs.", { :title => 'Jasmine results', :image => :success })

        Guard::JasmineHeadlessWebkitRunner.notify(file)
      end
    end

    context 'with failures' do
      let(:data) { "TOTAL||1||1||5||F" }

      it 'should notify with the right information' do
        Guard::Notifier.expects(:notify).with("1 test, 1 failures, 5.0 secs.", { :title => 'Jasmine results', :image => :failed })

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
