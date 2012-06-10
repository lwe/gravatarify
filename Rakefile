require 'bundler'
require 'rake/testtask'

include Rake::DSL
Bundler::GemHelper.install_tasks

desc 'Test the gravatarify plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

task :default => :test
