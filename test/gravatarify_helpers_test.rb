require 'test_helper'

class GravatarifyHelpersTest < Test::Unit::TestCase
  include Gravatarify::Helpers::Simple  
  
  def setup
    # just ensure that no global options are defined when starting next test
    reset_gravatarify!
  end

  context "#gravatar_url" do
    should "return same urls as build_gravatar_url" do
      assert_equal 'http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg', gravatar_url('bella@gmail.com')
      assert_equal 'http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg?d=x&s=16', gravatar_url('bella@gmail.com', :d => 'x', :s => 16)      
    end    
  end
end