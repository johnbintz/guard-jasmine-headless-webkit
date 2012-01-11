require 'bundler'
Bundler::GemHelper.install_tasks

include Rake::DSL if defined?(Rake::DSL)

desc 'Push everywhere!'
task :push_everywhere do
  system %{git push origin master}
  system %{git push guard master}
end

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

PLATFORMS = %w{1.8.7 1.9.2 ree 1.9.3}

def rvm_bundle(command = '')
  Bundler.with_clean_env do
    system %{bash -c 'unset BUNDLE_BIN_PATH && unset BUNDLE_GEMFILE && rvm #{PLATFORMS.join(',')} do bundle #{command}'}
  end
end

class SpecFailure < StandardError; end
class BundleFailure < StandardError; end

namespace :spec do
  desc "Run on three Rubies"
  task :platforms do
    rvm_bundle "update"
    rvm_bundle "exec rspec spec"
    rvm_bundle "exec cucumber"
    raise SpecError.new if $?.exitstatus != 0
  end
end

task :default => 'spec:platforms'

