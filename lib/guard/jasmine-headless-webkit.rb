require 'guard'
require 'guard/guard'
require 'guard/jasmine-headless-webkit/runner'

module Guard
  class JasmineHeadlessWebkit < Guard
    DEFAULT_EXTENSIONS = %w{js coffee}

    def initialize(watchers = [], options = {})
      super
      @options = {
        :all_on_start => true,
        :run_before => false,
        :valid_extensions => DEFAULT_EXTENSIONS
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
      paths = filter_paths(paths)
      @ran_jammit = false
      if run_before and run_jammit
        @ran_jammit = true
        if !paths.empty?
          JasmineHeadlessWebkitRunner.run(paths)
        else
          run_all
        end
      end
    end

    private
    def filter_paths(paths)
      paths.find_all { |path| File.extname(path)[valid_extensions] }
    end

    def valid_extensions
      %r{\.(#{@options[:valid_extensions].join('|')})$}
    end

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

