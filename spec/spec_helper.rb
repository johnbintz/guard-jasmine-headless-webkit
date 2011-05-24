require 'mocha'
require 'guard'

RSpec.configure do |config|
  config.mock_with :mocha
end

module Guard
  module UI
    class << self
      def info(*args)
      end
    end
  end
end

