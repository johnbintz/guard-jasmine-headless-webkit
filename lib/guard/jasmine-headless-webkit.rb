require 'guard'
require 'guard/guard'
require 'guard/jasmine-headless-webkit/runner'
require 'coffee-script'

module Guard
  class JasmineHeadlessWebkit < Guard
    DEFAULT_EXTENSIONS = %w{js coffee}

    attr_reader :files_to_rerun

    def initialize(watchers = [], options = {})
      super
      @options = {
        :all_on_start => true,
        :run_before => false,
        :valid_extensions => DEFAULT_EXTENSIONS
      }.merge(options)

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
        UI.info "Guard::JasmineHeadlessWebkit running all specs..."
        JasmineHeadlessWebkitRunner.run if run_all_things_before
        @ran_before = false
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
            UI.info "Guard::JasmineHeadlessWebkit running the following: #{paths.join(' ')}"
            if failed_files = JasmineHeadlessWebkitRunner.run(paths)
              @files_to_rerun = failed_files
            end
          else
            run_all
          end
        end
      end
    end

    private
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
      puts e.message
      puts e.backtrace.join("\n")
      puts
    end
  end

  class Dsl
    def newest_js_file(path)
      Dir[path + '*.{js,coffee}'].sort { |left, right| File.mtime(right) <=> File.mtime(left) }.first
    end
  end
end

