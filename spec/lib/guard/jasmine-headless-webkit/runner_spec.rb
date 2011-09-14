require 'spec_helper'
require 'guard/jasmine-headless-webkit/runner'
require 'fakefs/spec_helpers'

describe Guard::JasmineHeadlessWebkitRunner do
  describe '.run' do
    it 'should pass along options' do
      Jasmine::Headless::Runner.expects(:run).with(has_key(:full_run))

      Guard::JasmineHeadlessWebkitRunner.run([], :full_run => false)
    end
  end

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

        Guard::JasmineHeadlessWebkitRunner.notify(file).should == []
      end
    end

    context 'with failures' do
      let(:data) { <<-REPORT }
FAIL||Test||Two||file.js:50
TOTAL||1||1||5||F
REPORT

      it 'should notify with the right information' do
        Guard::Notifier.expects(:notify).with("1 test, 1 failures, 5.0 secs.", { :title => 'Jasmine results', :image => :failed })

        Guard::JasmineHeadlessWebkitRunner.notify(file).should == [ 'file.js' ]
      end
    end

    context 'system run interrupted' do
      let(:data) { '' }

      it 'should notify failure' do
        Guard::Notifier.expects(:notify).with("Spec runner interrupted!", { :title => 'Jasmine results', :image => :failed })

        Guard::JasmineHeadlessWebkitRunner.notify(file).should be_nil
      end
    end
  end
end
