# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "gravatarify/version"

Gem::Specification.new do |s|
  s.name        = "gravatarify"
  s.version     = Gravatarify::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Awesome gravatar support for Ruby (and Rails)."
  s.description = "Ruby (and Rails) Gravatar helpers with unique options like Proc's for default images, support for gravatar.com's multiple host names, ability to define reusable styles and much more..."

  s.required_ruby_version     = ">= 1.8.7"
  s.required_rubygems_version = ">= 1.3.6"

  s.authors  = ["Lukas Westermann"]
  s.email    = ["lukas.westermann@gmail.com"]
  s.homepage = "http://github.com/lwe/gravatarify"

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path     = 'lib'
  
  s.license          = 'MIT'
    
  s.add_development_dependency 'shoulda',       '>= 2.10.2'
  s.add_development_dependency 'rr',            '>= 0.10.5'
  s.add_development_dependency 'activesupport', '>= 3.0.0'
  s.add_development_dependency 'rake'
end

