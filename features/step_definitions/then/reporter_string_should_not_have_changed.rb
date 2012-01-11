Then /^the reporter string should not have changed$/ do
  @options[:reporters].should == @requested_reporter
end
