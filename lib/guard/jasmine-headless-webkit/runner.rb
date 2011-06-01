require 'guard/notifier'

module Guard
  class JasmineHeadlessWebkitRunner
    class << self
      def run(paths = [])
        file = Tempfile.new('guard-jasmine-headless-webkit')
        file.close

        system %{jasmine-headless-webkit --report #{file.path} -c #{paths.join(" ")}}

        notify(file.path)
      end

      def notify(file)
        if (data = File.read(file).strip).empty?
          Notifier.notify('Spec runner interrupted!', :title => 'Jasmine results', :image => :failed)
        else
          total, fails, any_console, secs = File.read(file).strip.split('/')

          Notifier.notify(message(total, fails, secs, any_console == "T"), :title => 'Jasmine results', :image => image(any_console == "T", fails))
          fails.to_i
        end
      end

      private
      def message(total, fails, secs, any_console)
        total_word = (total.to_i == 1) ? "test" : "tests"

        "#{total} #{total_word}, #{fails} failures, #{secs} secs#{any_console ? ', console.log used' : ''}."
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

