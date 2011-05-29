require 'guard/notifier'

module Guard
  class JasmineHeadlessWebkitRunner
    class << self
      def run(paths = [])
        file = Tempfile.new('guard-jasmine-headless-webkit')
        file.close

        system %{jasmine-headless-webkit --report #{file.path} -c #{paths.join(" ")}}

        total, fails, any_console, secs = File.read(file.path).strip.split('/')

        Notifier.notify(message(total, fails, secs, any_console == "T"), :title => 'Jasmine results', :image => image(any_console == "T", fails))
        fails.to_i
      end

      private
      def message(total, fails, secs, any_console)
        "#{total} tests, #{fails} failures, #{secs} secs#{any_console ? ', console.log used' : ''}."
      end

      def image(any_console, fails)
        if any_console
          :pending
        else
          if fails.to_i == 0
            :success
          else
            :failed
          end
        end
      end
    end
  end
end

