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
      JasmineHeadlessWebkitRunner.run if run_before and run_jammit
      @ran_jammit = false
    end

    def run_on_change(paths)
      @ran_jammit = false
      if run_before and run_jammit
        @ran_jammit = true
        run_all if JasmineHeadlessWebkitRunner.run(paths) == 0
      end
    end

    private
    def run_before
      if @options[:run_before]
        run_program(@options[:run_before])
      else
        true
      end
    end

    def run_jammit
      if @options[:jammit] && !@ran_jammit
        run_program("Jammit", %{jammit -f 2>/dev/null})
      else
        true
      end
    end

    def run_program(name, command = nil)
      command ||= name
      UI.info "Guard::JasmineHeadlessWebkit running #{name}..."
      system command
      $?.exitstatus == 0
    end
  end

  class Dsl
    def newest_js_file(path)
      Dir[path + '*.{js,coffee}'].sort { |left, right| File.mtime(right) <=> File.mtime(left) }.first
    end
  end
end

