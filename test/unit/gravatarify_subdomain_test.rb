require 'test_helper'
require 'net/http'
require 'net/https'
require 'uri'

class GravatarifySubdomainTest < Test::Unit::TestCase
  include Gravatarify::Base

  def setup; reset_gravatarify! end

  context "#subdomain(str)" do
    should "return consistent subdomain for each and every run (uses Zlib.crc32 and not String#hash)" do
      Gravatarify.subdomains = %w{a b c d e f g}
      assert_equal "a.", Gravatarify.subdomain("c") # => 112844655 % 7 = 0
      assert_equal "b.", Gravatarify.subdomain("asdf") # => 1361703869 % 7 = 1
      assert_equal "c.", Gravatarify.subdomain("some string") # => 4182587481 % 7 = 2
      assert_equal "d.", Gravatarify.subdomain("info@initech.com") # => 3555211446 % 7 = 3
      assert_equal "e.", Gravatarify.subdomain("a") # => 3904355907 % 7 = 4
      assert_equal "f.", Gravatarify.subdomain("support@initech.com") # => 3650283369 % 7 = 5
      assert_equal "g.", Gravatarify.subdomain("didum") # => 3257626035 % 7 = 6
    end
  end

  context "changing hosts through Gravatarify#subdomains" do
    should "override default subdomains (useful to e.g. switch back to 'www' only)" do
      Gravatarify.subdomains = %w{a b c d e f g}
      assert_equal "http://d.gravatar.com/avatar/4979dd9653e759c78a81d4997f56bae2.jpg", gravatar_url('info@initech.com')
      assert_equal "http://c.gravatar.com/avatar/d4489907918035d0bc6ff3f6c76e760d.jpg", gravatar_url('support@initech.com')
    end

    should "take in a string only argument, like www" do
      Gravatarify.subdomains = 'www'
      assert_equal "http://www.gravatar.com/avatar/4979dd9653e759c78a81d4997f56bae2.jpg", gravatar_url('info@initech.com')
      assert_equal "http://www.gravatar.com/avatar/d4489907918035d0bc6ff3f6c76e760d.jpg", gravatar_url('support@initech.com')
    end

    should "still work as expected if passed in `nil` and return urls without subdomain (default)" do
      Gravatarify.subdomains = []
      assert_equal "http://gravatar.com/avatar/4979dd9653e759c78a81d4997f56bae2.jpg", gravatar_url('info@initech.com')
      assert_equal "http://gravatar.com/avatar/d4489907918035d0bc6ff3f6c76e760d.jpg", gravatar_url('support@initech.com')
    end
  end

  context "with Net::HTTP the gravatar.com subdomains" do
    %w{ 0 1 2 3 www secure }.each do |subdomain|
      should "respond to http://#{subdomain}.gravatar.com/" do
        response = Net::HTTP.get_response URI.parse("http://#{subdomain}.gravatar.com/avatar/4979dd9653e759c78a81d4997f56bae2.jpg")
        assert_equal 200, response.code.to_i
        assert_equal "image/jpeg", response.content_type
      end

      should "respond to https://#{subdomain}.gravatar.com/ urls as well" do
        http = Net::HTTP.new("#{subdomain}.gravatar.com", 443)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER

        response = http.get '/avatar/4979dd9653e759c78a81d4997f56bae2.jpg'
        assert_equal 200, response.code.to_i
        assert_equal "image/jpeg", response.content_type
      end
    end

    should "not respond to 4.gravatar.com, if so add to subdomains dude!!!" do
      assert_raises(SocketError) { Net::HTTP.get_response URI.parse('http://4.gravatar.com/avatar/4979dd9653e759c78a81d4997f56bae2.jpg') }
    end
  end
end
