require 'guard/notifier'
require 'open3'

module Guard
  class JasmineHeadlessWebkitRunner
    class << self
      def run(paths = [])
        lines = [""]

        Open3.popen3(%{jasmine-headless-webkit -c #{paths.join(" ")}}) do |stdin, stdout, stderr|
          stdin.close
          stderr.close
          while !stdout.eof?
            $stdout.print (char = stdout.getc)
            $stdout.flush

            if char.chr == "\n"
              lines << ""
            else
              lines.last << char.chr
            end
          end
        end

        total, fails, secs = lines[-2].scan(%r{.* (\d+) tests, (\d+) failures, (.+) secs..*}).flatten

        any_console = lines.any? { |line| line['[console] '] }

        Notifier.notify(message(total, fails, secs, any_console), :title => 'Jasmine results', :image => image(any_console, fails))
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

