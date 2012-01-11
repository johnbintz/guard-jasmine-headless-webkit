When /^I specify the reporter "([^"]*)"$/ do |reporter|
  @requested_reporter = reporter

  @options = { :reporters => reporter }
end

