require 'guard'
require 'guard/guard'

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
      system %{jasmine-headless-webkit}
    end

    def run_on_change(paths)
      system %{jasmine-headless-webkit #{paths.join(" ")}}

      run_all if $?.exitstatus != 1
    end
  end

  class DSL
    def matching_js_file(path)
      Dir[path + '*.{js,coffee}'].sort { |left, right| File.mtime(right) <=> File.mtime(left) }.first
    end
  end
end

