require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'rr'

Test::Unit::TestCase.send :include, RR::Adapters::TestUnit

# Reset +Gravatarify+ to default hosts and cleared options
def reset_gravatarify!
  Gravatarify.options.clear
  Gravatarify.subdomains = Gravatarify::GRAVATAR_SUBDOMAINS
end