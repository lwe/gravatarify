require 'bundler'
require 'rake/testtask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the gravatarify plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

begin
  $:.push File.expand_path("../lib", __FILE__)
  require "gravatarify/version"  
  require 'yard'
  desc 'Generate documentation for gravatarify. (requires yard)'
  YARD::Rake::YardocTask.new(:doc) do |t|
    t.files = ['lib/**/*.rb']
    t.options = [
        "--readme", "README.md",
        "--title", "gravatarify (v#{Gravatarify::VERSION}) API Documentation"
    ]
 end
rescue LoadError
  puts "yard is required to build documentation: gem install yard"
end

desc 'Clean all generated files (.yardoc and doc/*)'
task :clean do |t|
  FileUtils.rm_rf "doc"
  FileUtils.rm_rf "pkg"
  FileUtils.rm_rf ".yardoc"
  Dir['**/*.rbc'].each { |f| File.unlink(f) }
end

namespace :metrics do
  desc 'Report all metrics, i.e. stats and code coverage.'
  task :all => [:stats, :coverage]
  
  desc 'Report code statistics for library and tests to shell.'
  task :stats do |t|
    require 'code_statistics'
    dirs = {
      'Libraries' => 'lib',
      'Unit tests' => 'test/unit'
    }.map { |name,dir| [name, File.join(File.dirname(__FILE__), dir)] }
    CodeStatistics.new(*dirs).to_s
  end
  
  desc 'Report code coverage to HTML (doc/coverage) and shell (requires rcov).'
  task :coverage do |t|
    rm_f "doc/coverage"
    mkdir_p "doc/coverage"
    rcov = %(rcov -Ilib:test --exclude '\/gems\/' -o doc/coverage -T test/unit/*_test.rb )
    system rcov
  end
  
  desc 'Report the fishy smell of bad code (requires reek)'
  task :smelly do |t|
    puts
    puts "* * * NOTE: reek currently reports several false positives,"
    puts "      eventhough it's probably good to check once in a while!"
    puts
    reek = %(reek -s lib)
    system reek
  end
end
