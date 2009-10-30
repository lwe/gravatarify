require 'test_helper'
require 'cgi'

class GravatarifyRackVsCgiTest < Test::Unit::TestCase
  include Gravatarify::Base

  # Remove Rack if defined
  def setup
    Object.send(:remove_const, :Rack) if defined?(Rack)    
  end

  # Reload Rack::Utils
  def teardown
    begin; require('rack/utils'); rescue LoadError; end
  end

  context "if Rack::Utils is not available, #gravatar_url" do
    should "fallback to CGI#escape" do
      assert !defined?(Rack::Utils), 'Rack::Utils should no longer be defined'
      assert defined?(CGI), "CGI should be defined"
      assert_equal "#{BELLA_AT_GMAIL_JPG}?escaped%2Fme=escaped%2Fme", gravatar_url('bella@gmail.com', 'escaped/me' => 'escaped/me')
    end
  end
end