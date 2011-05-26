require 'guard/notifier'

module Guard
  class JasmineHeadlessWebkitRunner
    class << self
      def run(paths = [])
        passes = fails = 0
        capturing = 0

        Open3.popen3(%{jasmine-headless-webkit -c #{paths.join(" ")}}) do |stdin, stdout, stderr|
          stdin.close
          stderr.close
          while !stdout.eof?
            $stdout.print (char = stdout.getc)
            $stdout.flush

            case char.chr
            when "\n"
              capturing += 1
            when '.'
              passes += 1 if capturing == 1
            when "F"
              fails += 1 if capturing == 1
            end
          end
        end

        Notifier.notify("#{passes + fails} examples, #{fails} failures", :title => 'Jasmine results', :image => (fails == 0) ? :success : :failes)
        $?.exitstatus
      end
    end
  end
end

