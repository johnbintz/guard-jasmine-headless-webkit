# Guard support for jasmine-headless-webkit

Add running your Jasmine specs to your `Guardfile` via [`jasmine-headless-webkit`](http://github.com/johnbintz/jasmine-headless-webkit/). Nice!

    guard 'jasmine-headless-webkit' do
      watch(%r{^app/assets/javascripts/(.*)\..*}) { |m| newest_js_file("spec/javascripts/#{m[1]}_spec") }
    end

`gem install guard-jasmine-headless-webkit` and then `guard init jasmine-headless-webkit` in your project directory to get started.
You should also put it in your `Gemfile` because, hey, why not, right?

Output is colored by default. If you want it not colored, place a `--no-colors` option into the project's or your
home folder's `.jasmine-headless-webkit` file.

## `guard` options

* `:all_on_start => false` to not run everything when starting, just like `guard-rspec`.
* `:run_before => "<command to run>` to run a command before running specs. If the command fails, the test run stops.
* `:jammit => true` to run `jammit -f 2>/dev/null` before the tests for the current file change are run.
* `:valid_extensions => %w{` to run `jammit -f 2>/dev/null` before the tests for the current file change are run.

## What's the deal with `newest_js_file`?

Since one could, theoretically, have a CoffeeScript app file and a JavaScript spec file (or vice versa), the search for the correct matching
file is a little more complicated. `newest_js_file` extends the Guard DSL to search the given path for the newest `.js` or `.coffee` file:

    newest_js_file('spec/javascripts/models/my_model')
      #=> search for Dir['spec/javascripts/models/my_model*.{js,coffee}'] and return the newest file found

If you 100% know you won't need that support, modify your `Guardfile` as appropriate.

## ...and the `.jst` file search?

I use [Backbone.js](http://documentcloud.github.com/backbone/) a lot, and I put my Underscore view templates in `app/views/*.jst` 
and mash them all together with [Jammit](https://github.com/documentcloud/jammit) for use in my apps. Feel free to change that, it's your `Guardfile` after all.
Or, try it. It's easy to do in your `assets.yml` file:

    templates:
    - app/views/*.jst

