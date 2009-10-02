require 'rake'
require 'rake/testtask'
require 'yard'

def gravatarify_version
  @gravatarify_version ||= (tmp = YAML.load(File.read('VERSION.yml'))) && [tmp[:major], tmp[:minor], tmp[:patch]] * '.'
end

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the gravatarify plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for gravatarify. (requires yard)'
YARD::Rake::YardocTask.new(:doc) do |t|
  t.files = ['lib/**/*.rb']
  t.options = [
      "--readme", "README.md",
      "--title", "gravatarify (v#{gravatarify_version}) API Documentation"
  ]
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "gravatarify"
    gemspec.summary = "Awesome gravatar support for ruby (and rails)."
    description = <<-DESC
    Yet another ruby/rails gravatar plugin - though, one with unique options like 
    `Proc`s for default images, or support for gravatar.com's multiple host names.
    DESC
    gemspec.description = description.strip
    gemspec.email = "lukas.westermann@gmail.com"
    gemspec.homepage = "http://github.com/lwe/gravatarify"
    gemspec.authors = ["Lukas Westermann"]
    gemspec.licenses = %w{LICENSE}
    gemspec.extra_rdoc_files = %w{README.md}
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

desc 'Clean all generated files (.yardoc and doc/*)'
task :clean do |t|
  FileUtils.rm_rf "doc"
  FileUtils.rm_rf "pkg"
  FileUtils.rm_rf "gravatarify.gemspec"
  FileUtils.rm_rf ".yardoc"
end

namespace :metrics do
  desc 'Report all metrics, i.e. stats and code coverage.'
  task :all => [:stats, :coverage]
  
  desc 'Report code statistics for library and tests to shell.'
  task :stats do |t|
    require 'code_statistics'
    dirs = {
      'Libraries' => 'lib',
      'Unit tests' => 'test'
    }.map { |name,dir| [name, File.join(File.dirname(__FILE__), dir)] }
    CodeStatistics.new(*dirs).to_s
  end
  
  desc 'Report code coverage to HTML (doc/coverage) and shell (requires rcov).'
  task :coverage do |t|
    rm_f "doc/coverage"
    mkdir_p "doc/coverage"
    rcov = %(rcov -Ilib:test --exclude '\/gems\/' -o doc/coverage -T test/*_test.rb )
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
