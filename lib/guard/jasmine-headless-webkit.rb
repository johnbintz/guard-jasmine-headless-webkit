require 'guard'
require 'guard/guard'
require 'guard/jasmine-headless-webkit/runner'

module Guard
  class JasmineHeadlessWebkit < Guard
    def initialize(watchers = [], options = {})
      super
      @options = {
        :all_on_start => true,
        :run_before => false
      }.merge(options)
    end

    def start
      UI.info "Guard::JasmineHeadlessWebkit is running."
      run_all if @options[:all_on_start]
    end

    def run_all
      JasmineHeadlessWebkitRunner.run if run_before
    end

    def run_on_change(paths)
      if run_before
        run_all if JasmineHeadlessWebkitRunner.run(paths) == 0
      end
    end

    private
    def run_before
      if @options[:run_before]
        UI.info "Guard::JasmineHeadlessWebkit running #{@options[:run_before]} first..."
        system @options[:run_before]
        $?.exitstatus == 0
      else
        true
      end
    end
  end

  class Dsl
    def newest_js_file(path)
      Dir[path + '*.{js,coffee}'].sort { |left, right| File.mtime(right) <=> File.mtime(left) }.first
    end
  end
end

