require 'bundler'
Bundler::GemHelper.install_tasks

desc 'Push everywhere!'
task :push_everywhere do
  system %{git push origin master}
  system %{git push guard master}
end
