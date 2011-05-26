require 'guard'
require 'guard/guard'
require 'guard/jasmine-headless-webkit/runner'

module Guard
  class JasmineHeadlessWebkit < Guard
    def initialize(watchers = [], options = {})
      super
      @options = {
        :all_on_start => true
      }.merge(options)
    end
    
    def start
      UI.info "Guard::JasmineHeadlessWebkit is running."
      run_all if @options[:all_on_start]
    end

    def run_all
      JasmineHeadlessWebkitRunner.run
    end

    def run_on_change(paths)
      run_all if JasmineHeadlessWebkitRunner.run(paths) == 0
    end
  end

  class Dsl
    def newest_js_file(path)
      Dir[path + '*.{js,coffee}'].sort { |left, right| File.mtime(right) <=> File.mtime(left) }.first
    end
  end
end

