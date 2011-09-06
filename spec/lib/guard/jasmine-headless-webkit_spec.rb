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
    let(:one_file) { %w{test.js} }

    context 'two files' do
      it "should only run one" do
        Guard::JasmineHeadlessWebkitRunner.expects(:run).with(one_file).returns(one_file)

        guard.run_on_change(%w{test.js test.js})
        guard.files_to_rerun.should == one_file
      end
    end

    context 'one file no priors' do
      it "should not run all" do
        Guard::JasmineHeadlessWebkitRunner.expects(:run).returns(one_file)

        guard.run_on_change(one_file)
        guard.files_to_rerun.should == one_file
      end
    end

    context 'one file one prior' do
      it "should not run all" do
        guard.instance_variable_set(:@files_to_rerun, [ "two.js" ])
        Guard::JasmineHeadlessWebkitRunner.expects(:run).with(one_file + [ "two.js" ]).returns(one_file)

        guard.run_on_change(one_file)
        guard.files_to_rerun.should == one_file
      end
    end

    context 'failed hard' do
      it "should not run all" do
        guard.instance_variable_set(:@files_to_rerun, one_file)
        Guard::JasmineHeadlessWebkitRunner.expects(:run).with(one_file).returns(nil)

        guard.run_on_change(one_file)
        guard.files_to_rerun.should == one_file
      end
    end

    context 'succeed, but still do not run all' do
      it "should run all" do
        Guard::JasmineHeadlessWebkitRunner.expects(:run).returns([])

        guard.run_on_change(one_file)
        guard.files_to_rerun.should == []
      end
    end

    context 'no files given, just run all' do
      it 'should run all but not run once' do
        Guard::JasmineHeadlessWebkitRunner.expects(:run).never
        guard.expects(:run_all).once

        guard.run_on_change([])
        guard.files_to_rerun.should == []
      end
    end

    context "Files I don't care about given, ignore" do
      it 'should run all but not run once' do
        Guard::JasmineHeadlessWebkitRunner.expects(:run).never
        guard.expects(:run_all).once

        guard.run_on_change(%w{test.jst})
        guard.files_to_rerun.should == []
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

  describe '#reload' do
    it 'should reset the state of the files_to_rerun' do
      Guard::UI.expects(:info).with(regexp_matches(/Resetting/))

      guard.instance_variable_set(:@files_to_rerun, "test")
      guard.reload
      guard.files_to_rerun.should == []
    end
  end
end
