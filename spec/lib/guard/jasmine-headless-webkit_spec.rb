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

        guard.run_on_change(%w{test})
      end
    end

    context 'succeed, run all' do
      it "should run all" do
        Guard::JasmineHeadlessWebkitRunner.expects(:run).returns(0)
        guard.expects(:run_all).once

        guard.run_on_change(%w{test})
      end
    end
  end

  context 'with run_before' do
    context 'with failing command' do
      before do
        Guard::JasmineHeadlessWebkitRunner.expects(:run).never
      end

      let(:options) { { :run_before => 'false' } }

      it "should run the command first" do
        guard.run_all
      end
    end

    context 'with succeeding command' do
      before do
        Guard::JasmineHeadlessWebkitRunner.expects(:run).once
      end

      let(:options) { { :run_before => 'true' } }

      it "should run the command first" do
        guard.run_all
      end
    end
  end
end
