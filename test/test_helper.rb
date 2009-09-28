require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'rr'

Test::Unit::TestCase.send :include, RR::Adapters::TestUnit
