require 'test_helper'

class GravatarifyRackVsCgiTest < Test::Unit::TestCase
  include Gravatarify::Base
  
  # Reload Rack::Utils
  def teardown
    begin; require('rack/utils'); rescue LoadError; end
  end

  context "if Rack::Utils is not available, #gravatarify" do
    setup do
      # Remove Rack if defined
      Object.send(:remove_const, :Rack) if defined?(Rack)
    end
    
    should "fallback to CGI#escape" do
      assert !defined?(Rack::Utils), 'Rack::Utils should no longer be defined'
      assert defined?(CGI), "CGI should be defined"
      assert_equal "http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg?escaped%2Fme=escaped%2Fme",
                   build_gravatar_url('bella@gmail.com', 'escaped/me' => 'escaped/me')
    end
  end
end