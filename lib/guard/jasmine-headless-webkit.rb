require 'guard'
require 'guard/guard'
require 'guard/jasmine-headless-webkit/runner'
require 'coffee-script'

module Guard
  class JasmineHeadlessWebkit < Guard
    DEFAULT_EXTENSIONS = %w{js coffee}

    ALL_SPECS_MESSAGE = "Guard::JasmineHeadlessWebkit running all specs..."
    SOME_SPECS_MESSAGE = "Guard::JasmineHeadlessWebkit running the following: %s"

    attr_reader :files_to_rerun

    DEFAULT_OPTIONS = {
      :all_on_start => true,
      :run_before => false,
      :valid_extensions => DEFAULT_EXTENSIONS
    }

    def initialize(watchers = [], options = {})
      super

      @options = DEFAULT_OPTIONS.merge(options)
      @filtered_options = options
      DEFAULT_OPTIONS.keys.each { |key| @filtered_options.delete(key) }

      UI.deprecation ":run_before is deprecated. Use guard-shell to do something beforehand. This will be removed in a future release." if @options[:run_before]

      @files_to_rerun = []
    end

    def start
      UI.info "Guard::JasmineHeadlessWebkit is running."
      run_all if @options[:all_on_start]
    end

    def reload
      @files_to_rerun = []
      UI.info "Resetting Guard::JasmineHeadlessWebkit failed files..."
    end

    def run_all
      run_something_and_rescue do
        @ran_before = false

        run_for_failed_files if run_all_things_before
      end
    end

    def run_on_change(paths)
      run_something_and_rescue do
        paths = filter_paths(paths)
        @ran_before = false
        if run_all_things_before
          @ran_before = true
          if !paths.empty?
            paths = (paths + @files_to_rerun).uniq

            run_for_failed_files(paths)
          else
            run_all
          end
        end
      end
    end

    private
    def run_for_failed_files(paths = [])
      if paths.empty?
        UI.info(ALL_SPECS_MESSAGE)
      else
        UI.info(SOME_SPECS_MESSAGE % paths.join(' '))
      end
      if failed_files = JasmineHeadlessWebkitRunner.run(paths, @filtered_options)
        failed_files = @files_to_rerun = failed_files.is_a?(Array) ? failed_files : []
      end

      failed_files && failed_files.empty?
    end

    def filter_paths(paths)
      paths.find_all { |path| File.extname(path)[valid_extensions] }.uniq
    end

    def valid_extensions
      %r{\.(#{@options[:valid_extensions].join('|')})$}
    end

    def run_before
      run_a_thing_before(:run_before, @options[:run_before])
    end

    def run_a_thing_before(option, *args)
      if @options[option] && !@ran_before
        run_program(*args)
      else
        true
      end
    end

    def run_all_things_before
      run_before
    end

    def run_program(name, command = nil)
      command ||= name
      UI.info "Guard::JasmineHeadlessWebkit running #{name}..."
      system command
      $?.exitstatus == 0
    end

    def run_something_and_rescue
      yield
    rescue ::CoffeeScript::CompilationError
    rescue StandardError => e
      if ENV['GUARD_ENV'] == 'test'
        raise e
      else
        puts e.message
        puts e.backtrace.join("\n")
        puts
      end
    end
  end

  class Dsl
    def newest_js_file(path)
      Dir[path + '*.{js,coffee}'].sort { |left, right| File.mtime(right) <=> File.mtime(left) }.first
    end
  end
end

