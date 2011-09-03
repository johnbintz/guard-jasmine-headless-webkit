require 'guard/notifier'
require 'jasmine-headless-webkit'

module Guard
  class JasmineHeadlessWebkitRunner
    class << self
      def run(paths = [])
        file = Tempfile.new('guard-jasmine-headless-webkit')
        file.close

        Jasmine::Headless::Runner.run(:report => file.path, :colors => true, :files => paths)

        notify(file.path)
      end

      def notify(file)
        if (report = Jasmine::Headless::Report.load(file)).valid?
          Notifier.notify(message(report.total, report.failed, report.time, report.has_used_console?), :title => 'Jasmine results', :image => image(report.has_used_console?, report.failed))
          report.failed
        else
          raise StandardError.new("invalid report")
        end
      rescue Exception => e
        Notifier.notify('Spec runner interrupted!', :title => 'Jasmine results', :image => :failed)
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

