## Guard support for jasmine-headless-webkit

Add running your Jasmine specs to your `Guardfile` via [`jasmine-headless-webkit`](http://github.com/johnbintz/jasmine-headless-webkit/). Nice!

    guard 'jasmine-headless-webkit' do
      watch(%r{^app/assets/javascripts/(.*)\..*}) { |m| newest_js_file("spec/javascripts/#{m[1]}") }
    end

`gem install guard-jasmine-headless-webkit` and then `guard init jasmine-headless-webkit` in your project directory to get started.

## `guard` options

* `:all_on_start => false` to not run everything, just like `guard-rspec`

## What's the deal with `newest_js_file`?

Since one could, theoretically, have a CoffeeScript app file and a JavaScript spec file (or vice versa), the search for the correct matching
file is a little more complicated. `newest_js_file` extends the Guard DSL to search the given path for the newest `.js` or `.coffee` file:

    newest_js_file('spec/javascripts/models/my_model')
      #=> search for Dir['spec/javascripts/models/my_model*.{js,coffee}'] and return the newest file found

If you 100% know you won't need that support, modify your `Guardfile` as appropriate.

## ...and the `.jst` file search?

I use Backbone.js a lot, and I put my view templates in `app/views/*.jst` and mash them all together with Jammit for use in my apps. Feel free
to change that, it's your Guardfile after all.

