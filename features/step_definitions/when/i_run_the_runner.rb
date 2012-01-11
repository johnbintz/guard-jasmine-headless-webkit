When /^I run the runner$/ do
  Guard::JasmineHeadlessWebkit::Runner.run(@paths, @options)
end
