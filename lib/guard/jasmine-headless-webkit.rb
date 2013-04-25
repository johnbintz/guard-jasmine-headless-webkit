require 'guard'
require 'guard/guard'
require 'coffee-script'
require 'ember_script'

module Guard
  class JasmineHeadlessWebkit < Guard
    autoload :Runner,  'guard/jasmine-headless-webkit/runner'

    DEFAULT_EXTENSIONS = %w{js coffee em}

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
        run_for_failed_files
      end
    end

    def run_on_change(paths)
      run_something_and_rescue do
        if !(paths = filter_paths(paths)).empty?
          paths = (paths + @files_to_rerun).uniq

          run_for_failed_files(paths)
        else
          run_all
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
      failed_files = Runner.run(paths, @filtered_options)
      @files_to_rerun = failed_files || paths

      failed_files && @files_to_rerun.empty?
    end

    def filter_paths(paths)
      paths.collect { |path| Dir[path] }.flatten.find_all { |path| File.extname(path)[valid_extensions] }.collect { |path| File.expand_path(path) }.uniq
    end

    def valid_extensions
      %r{\.(#{@options[:valid_extensions].join('|')})$}
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
    rescue ::ExecJS::ProgramError
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
      Dir[path + '*.{js,coffee,em}'].sort { |left, right| File.mtime(right) <=> File.mtime(left) }.first
    end
  end
end

