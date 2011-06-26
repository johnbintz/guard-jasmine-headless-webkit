require 'guard'
require 'guard/guard'
require 'guard/jasmine-headless-webkit/runner'
require 'coffee-script'

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
      UI.info "Guard::JasmineHeadlessWebkit running all specs..."
      JasmineHeadlessWebkitRunner.run if run_all_things_before
      @ran_before = false
    rescue CoffeeScript::CompilationError
    rescue StandardError => e
      puts e.message
      puts e.backtrace.join("\n")
      puts
    end

    def run_on_change(paths)
      paths = filter_paths(paths)
      @ran_before = false
      if run_all_things_before
        @ran_before = true
        if !paths.empty?
          UI.info "Guard::JasmineHeadlessWebkit running the following: #{paths.join(' ')}"
          JasmineHeadlessWebkitRunner.run(paths)
        else
          run_all
        end
      end
    rescue CoffeeScript::CompilationError
    rescue StandardError => e
      puts e.message
      puts e.backtrace.join("\n")
      puts
    end

    private
    def filter_paths(paths)
      paths.find_all { |path| File.extname(path)[valid_extensions] }
    end

    def valid_extensions
      %r{\.(#{@options[:valid_extensions].join('|')})$}
    end

    def run_before
      run_a_thing_before(:run_before, @options[:run_before])
    end

    def run_jammit
      $stderr.puts "Jammit support is deprecated and will be removed in the future. Use guard-jammit instead." if @options[:jammit]
      run_a_thing_before(:jammit, "Jammit", %{jammit -f 2>/dev/null})
    end

    def run_rails_assets
      run_a_thing_before(:rails_assets, "Rails Assets", %{rake assets:precompile:for_testing})
    end

    def run_a_thing_before(option, *args)
      if @options[option] && !@ran_before
        run_program(*args)
      else
        true
      end
    end

    def run_all_things_before
      run_before and run_rails_assets and run_jammit
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

