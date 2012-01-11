require 'guard/notifier'
require 'jasmine-headless-webkit'

module Guard
  class JasmineHeadlessWebkit
    class Runner
      def self.run(paths = [], options = {})
        report_file = notify_report_file

        options = options.merge(:reporters => process_reporters(options[:reporters], report_file), :colors => true, :files => paths)

        Jasmine::Headless::Runner.run(options)

        notify(report_file)
      end

      def self.notify_report_file
        file = Tempfile.new('guard-jasmine-headless-webkit')
        file.close
        file.path
      end

      def self.process_reporters(reporters, report_file)
        reporters ||= 'Console'

        out = []

        reporters.split(' ').each do |reporter|
          name, file = reporter.split(':', 2)

          out << [ name ]
          out.last << file if file && !file.empty?
        end

        out + [ [ 'File', report_file ] ]
      end

      def self.notify(file)
        if (report = Jasmine::Headless::Report.load(file)).valid?
          Notifier.notify(message(report.total, report.failed, report.time, report.has_used_console?), :title => 'Jasmine results', :image => image(report.has_used_console?, report.failed))
          report.failed_files
        else
          raise Jasmine::Headless::InvalidReport
        end
      rescue Jasmine::Headless::InvalidReport => e
        Notifier.notify('Spec runner interrupted!', :title => 'Jasmine results', :image => :failed)
        false
      end

      private
      def self.message(total, fails, secs, any_console)
        total_word = (total.to_i == 1) ? "test" : "tests"

        "#{total} #{total_word}, #{fails} failures, #{secs} secs#{any_console ? ', console.log used' : ''}."
      end

      def self.image(any_console, fails)
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
