require 'rspec'
require 'mocha'
require 'fakefs/safe'

require 'jasmine-headless-webkit'
require 'guard/jasmine-headless-webkit'

require 'coffee-script'

World(Mocha::API)

Before do
  mocha_setup

  FakeFS.activate!

  @report_file = 'notify-file'
  @paths = []
end

After do
  begin
    mocha_verify
  ensure
    mocha_teardown
  end

  FakeFS.deactivate!
end

