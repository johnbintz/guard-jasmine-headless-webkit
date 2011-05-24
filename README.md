Whoa, it works with Guard! So fast!

    guard 'jasmine-headless-webkit' do
      watch(%r{^app/assets/javascripts/(.*)\..*}) { |m| newest_js_file("spec/javascripts/#{m[1]}") }
    end

Guard options:

* `:all_on_start => false` to not run everything

