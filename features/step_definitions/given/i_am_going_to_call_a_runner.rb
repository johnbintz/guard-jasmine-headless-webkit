Given /^I am going to call a JHW runner with the following reporters:$/ do |table|
  reporters = []

  table.rows.each do | name, file |
    reporters << [ name ]

    reporters.last << file if !file.empty?
  end

  Jasmine::Headless::Runner.expects(:run).with(has_entry(:reporters => reporters))
  Guard::JasmineHeadlessWebkit::Runner.expects(:notify)
end

