require 'test_helper'
require 'gravatarify/base'
require 'gravatarify/object_support'

class GravatarifyObjectSupportTest < Test::Unit::TestCase
  def setup; reset_gravatarify! end
  
  context "#gravatarify" do
    should "add support for #gravatar_url to POROs (plain old ruby objects, yeah POJO sounds better!)" do
      poro = Class.new do
        include Gravatarify::ObjectSupport
        gravatarify
        def email; "mike@shiva.ch" end
      end
      assert_equal "http://0.gravatar.com/avatar/1b2818d77eadd6c9dbbe7f3beb1492c3.jpg", poro.new.gravatar_url
      assert_equal "https://secure.gravatar.com/avatar/1b2818d77eadd6c9dbbe7f3beb1492c3.jpg", poro.new.gravatar_url(:secure => true)
      assert_equal "http://0.gravatar.com/avatar/1b2818d77eadd6c9dbbe7f3beb1492c3.gif?r=x&s=16", poro.new.gravatar_url(:filetype => :gif, :rating => :x, :size => 16)
    end
    
    should "allow some default options to be passed, which can be overriden locally, though" do
      poro = Class.new do
        include Gravatarify::ObjectSupport
        gravatarify :secure => true, :filetype => :gif
        def email; "mike@shiva.ch" end
      end
      assert_equal "https://secure.gravatar.com/avatar/1b2818d77eadd6c9dbbe7f3beb1492c3.gif", poro.new.gravatar_url
      assert_equal "http://0.gravatar.com/avatar/1b2818d77eadd6c9dbbe7f3beb1492c3.gif", poro.new.gravatar_url(:secure => false)
      assert_equal "https://secure.gravatar.com/avatar/1b2818d77eadd6c9dbbe7f3beb1492c3.jpg?r=x&s=16", poro.new.gravatar_url(:filetype => :jpg, :rating => :x, :size => 16)      
    end
    
    should "still respect options set by Gravatarify#options" do
      Gravatarify.options[:size] = 20
      poro = Class.new do
        include Gravatarify::ObjectSupport
        gravatarify
        def email; "mike@shiva.ch" end
      end
      assert_equal "http://0.gravatar.com/avatar/1b2818d77eadd6c9dbbe7f3beb1492c3.jpg?s=20", poro.new.gravatar_url
    end
    
    should "be able to override options set by Gravatarify#options" do
      Gravatarify.options[:size] = 20
      poro = Class.new do
        include Gravatarify::ObjectSupport
        gravatarify :size => 25
        def email; "mike@shiva.ch" end
      end
      assert_equal "http://0.gravatar.com/avatar/1b2818d77eadd6c9dbbe7f3beb1492c3.jpg?s=25", poro.new.gravatar_url
    end    
  end
  
  context "#gravatarify with custom fields" do
    should "detect and use the 'email' field automatically" do
      poro = Class.new do
        include Gravatarify::ObjectSupport
        gravatarify
        def email; "mike@shiva.ch" end
      end
      assert_equal "http://0.gravatar.com/avatar/1b2818d77eadd6c9dbbe7f3beb1492c3.jpg", poro.new.gravatar_url
    end
    
    should "fallback to 'mail' if 'email' is not defined" do
      poro = Class.new do
        include Gravatarify::ObjectSupport
        gravatarify
        def mail; "mike@shiva.ch" end
      end
      assert_equal "http://0.gravatar.com/avatar/1b2818d77eadd6c9dbbe7f3beb1492c3.jpg", poro.new.gravatar_url      
    end
    
    should "raise NoMethodError if object does not respond to source" do
      poro = Class.new do
        include Gravatarify::ObjectSupport
        gravatarify
      end
      assert_raise(NoMethodError) { poro.new.gravatar_url }
    end
    
    should "allow to set custom source, like author_email" do
      poro = Class.new do
        include Gravatarify::ObjectSupport
        gravatarify :author_email
        def author_email; "mike@shiva.ch" end
      end
      assert_equal "http://0.gravatar.com/avatar/1b2818d77eadd6c9dbbe7f3beb1492c3.jpg", poro.new.gravatar_url      
    end
    
    should "allow multiple sources to be defined, yet still handle options!" do
      poro = Class.new do
        include Gravatarify::ObjectSupport
        gravatarify :email, :employee_email, :default => Proc.new { |*args| "http://initech.com/avatar-#{args.first[:size] || 80}.jpg" }
        def email; "info@initech.com" end
        def employee_email; "peter.gibbons@initech.com" end
      end
      assert_equal "http://2.gravatar.com/avatar/4979dd9653e759c78a81d4997f56bae2.jpg?d=http%3A%2F%2Finitech.com%2Favatar-20.jpg&s=20", poro.new.gravatar_url(:size => 20)
      assert_equal "http://0.gravatar.com/avatar/cb7865556d41a3d800ae7dbb31d51d54.jpg?d=http%3A%2F%2Finitech.com%2Favatar-25.jpg&s=25", poro.new.employee_gravatar_url(:size => 25)
    end
  end
end