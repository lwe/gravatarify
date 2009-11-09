require 'test_helper'
require 'cgi'

class GravatarifyRackVsCgiTest < Test::Unit::TestCase
  include Gravatarify

  context "if Rack::Utils is not available, Utils#escape and Utils#escape_html" do
    should "fallback to CGI#escape" do
      puts "\n>>>> next two constant warnings can be ignored!"
      Gravatarify::Utils::RACK_AVAILABLE = false
      assert_equal "asd%25%3D%40%23", Utils.escape('asd%=@#')
      assert_equal "&lt;html", Utils.escape_html("<html")
      Gravatarify::Utils::RACK_AVAILABLE = !!defined?(::Rack::Utils)
      puts "<<<<"
    end
  end
end