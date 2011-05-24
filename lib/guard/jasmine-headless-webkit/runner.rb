module Guard
  class JasmineHeadlessWebkitRunner
    class << self
      def run(paths = [])
        system %{jasmine-headless-webkit #{paths.join(" ")}}
        $?.exitstatus
      end
    end
  end
end

