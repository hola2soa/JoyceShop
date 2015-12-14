require 'rake/testtask'

task :default => [:spec]

desc 'run specs'
Rake::TestTask.new(name=:spec) do |t|
  t.pattern = 'spec/*_spec.rb'
end
