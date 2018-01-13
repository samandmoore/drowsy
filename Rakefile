require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubycritic/rake_task'

RSpec::Core::RakeTask.new(:spec)
RubyCritic::RakeTask.new do |task|
  task.paths   = FileList['lib']
end

task default: :spec
