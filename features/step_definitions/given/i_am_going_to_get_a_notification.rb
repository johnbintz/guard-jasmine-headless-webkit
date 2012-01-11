Given /^I am going to get a notification file$/ do
  Guard::JasmineHeadlessWebkit::Runner.stubs(:notify_report_file).returns(@report_file)
end
