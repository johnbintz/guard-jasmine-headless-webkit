# Guard support for jasmine-headless-webkit

Add running your Jasmine specs to your `Guardfile` via [`jasmine-headless-webkit`](http://github.com/johnbintz/jasmine-headless-webkit/). Nice!

``` ruby
guard 'jasmine-headless-webkit' do
  watch(%r{^app/assets/javascripts/(.*)\..*}) { |m| newest_js_file("spec/javascripts/#{m[1]}_spec") }
end
```

`gem install guard-jasmine-headless-webkit` and then `guard init jasmine-headless-webkit` in your project directory to get started.
You should also put it in your `Gemfile` because, hey, why not, right?

Output is colored by default. If you want it not colored, place a `--no-colors` option into the project's or your
home folder's `.jasmine-headless-webkit` file.

## `guard` options

* `:all_on_start => false` to not run everything when starting, just like `guard-rspec`.
* `:valid_extensions => %w{js coffee}` to only trigger `run_on_change` events for files with these extensions. Forces Guard to re-run all tests when any other matched file changes.
* All other options from `Jasmine::Headless::Runner`: (see the [list of available options](https://github.com/johnbintz/jasmine-headless-webkit/blob/master/lib/jasmine/headless/options.rb#L11A))

## Using with .erb files in the Rails 3.1 Asset Pipeline and/or Jammit

If your code required Jammit or ERB templates, which aren't directly supported by `jasmine-headledd-webkit`,
use [`guard-rails-assets`](https://github.com/dnagir/guard-rails-assets) chained in before `guard-jasmine-headless-webkit` to precompile your application
code for testing:

``` ruby
guard 'rails-assets' do
  watch(%r{^app/assets/javascripts/.*})
end

guard 'jasmine-headless-webkit' do
  watch(%r{^public/assets/.*\.js})
  ... specs ...
end
```

Do the same for Jammit, using [`guard-jammit`](http://github.com/guard/guard-jammit).

### `guard-jammit` and Jammit >= 0.6.0

Jammit >= 0.6.0 changed how it determines the Rails environment. Use [my fork of `guard-jammit`](http://github.com/johnbintz/guard-jammit) until it's fixed upstream.

## What's the deal with `newest_js_file`?

Since one could, theoretically, have a CoffeeScript app file and a JavaScript spec file (or vice versa), the search for the correct matching
file is a little more complicated. `newest_js_file` extends the Guard DSL to search the given path for the newest `.js` or `.coffee` file:

    newest_js_file('spec/javascripts/models/my_model')
      #=> search for Dir['spec/javascripts/models/my_model*.{js,coffee}'] and return the newest file found

If you 100% know you won't need that support, modify your `Guardfile` as appropriate.

## License

This library is released under the MIT license:

* http://www.opensource.org/licenses/MIT
