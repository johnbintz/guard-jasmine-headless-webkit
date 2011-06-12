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

  describe 'run jammit first' do
    context 'run on run_all if called first' do
      before do
        guard.expects(:run_program).once.with('Jammit', regexp_matches(/jammit/)).returns(true)
        Guard::JasmineHeadlessWebkitRunner.expects(:run).once
      end

      let(:options) { { :jammit => true } }

      it "should run jammit first" do
        guard.run_all
      end
    end

    context 'only run once if run_on_change is successful' do
      before do
        guard.expects(:run_program).once.with('Jammit', regexp_matches(/jammit/)).returns(true)
        Guard::JasmineHeadlessWebkitRunner.expects(:run).once.returns(0)
      end

      let(:options) { { :jammit => true } }

      it "should run jammit only once" do
        guard.run_on_change(%w{path.js})
      end
    end
  end

  describe 'run rails_assets first' do
    context 'run on run_all if called first' do
      before do
        guard.expects(:run_program).with('Rails Assets', regexp_matches(/assets:precompile:for_testing/)).once.returns(true)
        Guard::JasmineHeadlessWebkitRunner.expects(:run).once
      end

      let(:options) { { :rails_assets => true } }

      it "should run rails assets first" do
        guard.run_all
      end
    end

    context 'only run once if run_on_change is successful' do
      before do
        guard.expects(:run_program).with('Rails Assets', regexp_matches(/assets:precompile:for_testing/)).once.returns(true)
        Guard::JasmineHeadlessWebkitRunner.expects(:run).once.returns(0)
      end

      let(:options) { { :rails_assets => true } }

      it "should run rails assets only once" do
        guard.run_on_change(%w{path.js})
      end
    end
  end
end
