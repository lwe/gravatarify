# -*- encoding: utf-8 -*-
require File.expand_path('../lib/gravatarify/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = "gravatarify"
  gem.version     = Gravatarify::VERSION
  gem.summary     = "Awesome gravatar support for Ruby (and Rails)."
  gem.description = "Ruby (and Rails) Gravatar helpers with unique options like Proc's for default images, support for gravatar.com's multiple host names, ability to define reusable styles and much more..."

  gem.required_ruby_version     = ">= 1.8.7"
  gem.required_rubygems_version = ">= 1.3.6"

  gem.authors  = ["Lukas Westermann"]
  gem.email    = ["lukas.westermann@gmail.com"]
  gem.homepage = "https://github.com/lwe/gravatarify"

  gem.files            = %w{.travis.yml .gitignore Gemfile Rakefile LICENSE README.md gravatarify.gemspec} + Dir['{lib,test}/**/*.rb']
  gem.test_files       = gem.files.grep(%r{^test/})
  gem.require_paths    = ['lib']

  gem.license          = 'MIT'

  gem.add_development_dependency 'shoulda',       '>= 2.10.2'
  gem.add_development_dependency 'rr',            '>= 0.10.5'
  gem.add_development_dependency 'activesupport', '>= 3.0.0'
  gem.add_development_dependency 'rake'
end
