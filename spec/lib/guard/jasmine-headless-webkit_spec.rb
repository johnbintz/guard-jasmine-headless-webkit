require 'spec_helper'
require 'guard/jasmine-headless-webkit'

describe Guard::JasmineHeadlessWebkit do
  let(:guard) { Guard::JasmineHeadlessWebkit.new([], options) }

  let(:options) { {} }

  describe "#start" do
    context 'no all on start' do
      let(:options) { { :all_on_start => false } }

      it "should not run all" do
        guard.expects(:run_all).never
        guard.start
      end
    end

    context 'all on start' do
      let(:options) { { :all_on_start => true } }

      it "should not run all" do
        guard.expects(:run_all).once
        guard.start
      end
    end
  end

  describe '#run_on_change' do
    context 'two files' do
      it "should only run one" do
        Guard::JasmineHeadlessWebkitRunner.expects(:run).with(%w{test.js}).returns(1)
        guard.expects(:run_all).never

        guard.run_on_change(%w{test.js test.js})
      end
    end

    context 'jhw call fails' do
      it "should not run all" do
        Guard::JasmineHeadlessWebkitRunner.expects(:run).returns(1)
        guard.expects(:run_all).never

        guard.run_on_change(%w{test.js})
      end
    end

    context 'succeed, but still do not run all' do
      it "should run all" do
        Guard::JasmineHeadlessWebkitRunner.expects(:run).returns(0)
        guard.expects(:run_all).never

        guard.run_on_change(%w{test.js})
      end
    end

    context 'no files given, just run all' do
      it 'should run all but not run once' do
        Guard::JasmineHeadlessWebkitRunner.expects(:run).never
        guard.expects(:run_all).once

        guard.run_on_change([])
      end
    end

    context "Files I don't care about given, ignore" do
      it 'should run all but not run once' do
        Guard::JasmineHeadlessWebkitRunner.expects(:run).never
        guard.expects(:run_all).once

        guard.run_on_change(%w{test.jst})
      end
    end
  end

  context 'with run_before' do
    context 'with failing command' do
      before do
        Guard::JasmineHeadlessWebkitRunner.expects(:run).never
        Guard::UI.expects(:info).with(regexp_matches(/false/))
        Guard::UI.expects(:info).with(regexp_matches(/running all/))
      end

      let(:options) { { :run_before => 'false' } }

      it "should run the command first" do
        guard.run_all
      end
    end

    context 'with succeeding command' do
      before do
        Guard::JasmineHeadlessWebkitRunner.expects(:run).once
        Guard::UI.expects(:info).with(regexp_matches(/true/))
        Guard::UI.expects(:info).with(regexp_matches(/running all/))
      end

      let(:options) { { :run_before => 'true' } }

      it "should run the command first" do
        guard.run_all
      end
    end
  end
end
