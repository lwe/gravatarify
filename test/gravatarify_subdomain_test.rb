require 'test_helper'
require 'gravatarify/base'

class GravatarifySubdomainTest < Test::Unit::TestCase
  include Gravatarify::Base
  
  def setup; reset_gravatarify! end
    
  context "changing hosts through Gravatarify#subdomains" do
    should "override default subdomains (useful to e.g. switch back to 'www' only)" do
      Gravatarify.subdomains = ['0', '1']
      assert_equal "http://0.gravatar.com/avatar/4979dd9653e759c78a81d4997f56bae2.jpg", build_gravatar_url('info@initech.com')
      assert_equal "http://1.gravatar.com/avatar/d4489907918035d0bc6ff3f6c76e760d.jpg", build_gravatar_url('support@initech.com')
    end
    
    should "take in a string only argument, like www (and be aliased to 'subdomain' to singularize it :D)" do
      Gravatarify.subdomain = 'www'
      assert_equal "http://www.gravatar.com/avatar/4979dd9653e759c78a81d4997f56bae2.jpg", build_gravatar_url('info@initech.com')
      assert_equal "http://www.gravatar.com/avatar/d4489907918035d0bc6ff3f6c76e760d.jpg", build_gravatar_url('support@initech.com')      
    end
    
    should "still work as expected if passed in `nil` and return urls with default subdomain `www`" do
      Gravatarify.subdomain = nil
      assert_equal "http://www.gravatar.com/avatar/4979dd9653e759c78a81d4997f56bae2.jpg", build_gravatar_url('info@initech.com')
      assert_equal "http://www.gravatar.com/avatar/d4489907918035d0bc6ff3f6c76e760d.jpg", build_gravatar_url('support@initech.com')            
    end
  end
  
  context "Gravatarify#use_only_www!" do
    should "only generate www.gravatar.com urls" do
      Gravatarify.use_www_only!
      assert_equal "http://www.gravatar.com/avatar/4979dd9653e759c78a81d4997f56bae2.jpg", build_gravatar_url('info@initech.com')
      assert_equal "http://www.gravatar.com/avatar/d4489907918035d0bc6ff3f6c76e760d.jpg", build_gravatar_url('support@initech.com')      
    end
  end  
end