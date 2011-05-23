# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "guard/jasmine-headless-webkit/version"

Gem::Specification.new do |s|
  s.name        = "guard-jasmine-headless-webkit"
  s.version     = Guard::JasmineHeadlessWebkit::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["John Bintz"]
  s.email       = ["john@coswellproductions.com"]
  s.homepage    = ""
  s.summary     = %q{Run jasmine-headless-webkit using guard}
  s.description = %q{Run jasmine-headless-webkit using guard}

  s.rubyforge_project = "guard-jasmine-headless-webkit"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
