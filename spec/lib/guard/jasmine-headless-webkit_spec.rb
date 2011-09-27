require 'spec_helper'
require 'guard/jasmine-headless-webkit'
require 'fakefs/spec_helpers'

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

    context 'run_before' do
      let(:options) { { :run_before => true, :all_on_start => false } }

      it "should warn about deprecation" do
        Guard::UI.expects(:deprecation).at_least_once
        guard.start
      end
    end
  end

  describe '#run_all' do
    before do
      guard.stubs(:run_all_things_before).returns(true)
    end

    context 'fails' do
      it 'should return false' do
        Guard::JasmineHeadlessWebkitRunner.stubs(:run).returns(['file.js'])

        guard.run_all.should be_false
        guard.files_to_rerun.should == ['file.js']
      end
    end

    context 'succeeds' do
      it 'should return true' do
        Guard::JasmineHeadlessWebkitRunner.stubs(:run).returns([])

        guard.run_all.should be_true
        guard.files_to_rerun.should == []
      end
    end

    context 'pass along jhw options' do
      let(:options) { { :all_on_start => false, :full_run => false } }

      it 'should only pass along jhw options' do
        Guard::JasmineHeadlessWebkitRunner.expects(:run).with([], :full_run => false)

        guard.run_all
      end
    end
  end

  describe '#run_on_change' do
    include FakeFS::SpecHelpers

    let(:one_file) { %w{test.js} }

    def absolute(file)
      case file
      when Array
        file.collect { |f| absolute(f) }
      else
        File.expand_path(file)
      end
    end

    before do
      File.open(one_file.first, 'wb')
    end

    context 'two files' do
      it "should only run one" do
        Guard::JasmineHeadlessWebkitRunner.expects(:run).with(absolute(one_file), {}).returns(one_file)

        guard.run_on_change(%w{test.js test.js}).should be_false
        guard.files_to_rerun.should == one_file
      end
    end

    context 'one file no priors' do
      it "should not run all" do
        Guard::JasmineHeadlessWebkitRunner.expects(:run).returns(one_file)

        guard.run_on_change(one_file).should be_false
        guard.files_to_rerun.should == one_file
      end
    end

    context 'one file one prior' do
      it "should not run all" do
        guard.instance_variable_set(:@files_to_rerun, [ "two.js" ])
        Guard::JasmineHeadlessWebkitRunner.expects(:run).with(absolute(one_file) + [ "two.js" ], {}).returns(one_file)

        guard.run_on_change(one_file).should be_false
        guard.files_to_rerun.should == one_file
      end
    end

    context 'failed hard' do
      it "should not run all" do
        guard.instance_variable_set(:@files_to_rerun, absolute(one_file))
        Guard::JasmineHeadlessWebkitRunner.expects(:run).with(absolute(one_file), {}).returns(false)

        guard.run_on_change(one_file).should be_false
        guard.files_to_rerun.should == absolute(one_file)
      end
    end

    context 'succeed, but still do not run all' do
      it "should run all" do
        Guard::JasmineHeadlessWebkitRunner.expects(:run).returns([])

        guard.run_on_change(one_file).should be_true
        guard.files_to_rerun.should == []
      end
    end

    context 'no files given, just run all' do
      it 'should run all but not run once' do
        Guard::JasmineHeadlessWebkitRunner.expects(:run).never
        guard.expects(:run_all).once.returns(true)

        guard.run_on_change([]).should be_true
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

    context 'glob given' do
      let(:files) { %w{file1.js file2.js other.js} }

      before do
        files.each { |file| File.open(file, 'wb') }
      end

      context 'not a duplicate' do
        it 'should expand the glob' do
          Guard::JasmineHeadlessWebkitRunner.expects(:run).with(absolute(%w{file1.js file2.js}), {}).returns(false)

          guard.run_on_change(%w{file*.js})
        end
      end

      context 'a duplicate' do
        it 'should expand the glob and uniq' do
          guard.instance_variable_set(:@files_to_rerun, absolute(%w{file1.js}))
          Guard::JasmineHeadlessWebkitRunner.expects(:run).with(absolute(%w{file1.js file2.js}), {}).returns(false)

          guard.run_on_change(%w{file*.js})
        end
      end
    end
  end

  context 'with run_before' do
    context 'with failing command' do
      before do
        Guard::JasmineHeadlessWebkitRunner.expects(:run).never
        Guard::UI.expects(:info).with(regexp_matches(/false/))
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
