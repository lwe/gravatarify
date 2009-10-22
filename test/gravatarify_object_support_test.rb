require 'test_helper'

class PoroUser
  include Gravatarify::ObjectSupport
  attr_accessor :email, :gender
  def initialize(attributes = {})
    attributes.each do |key, value|
      self.send "#{key}=", value
    end
  end
end

class GravatarifyObjectSupportTest < Test::Unit::TestCase
  def setup; reset_gravatarify! end
  
  context "#gravatarify" do
    should "add support for #gravatar_url to POROs (plain old ruby objects, yeah POJO sounds better!)" do
      poro = Class.new(PoroUser) { gravatarify }
      mike_shiva = poro.new(:email => 'mike@shiva.ch')
      assert_equal "http://0.gravatar.com/avatar/1b2818d77eadd6c9dbbe7f3beb1492c3.jpg", mike_shiva.gravatar_url
      assert_equal "https://secure.gravatar.com/avatar/1b2818d77eadd6c9dbbe7f3beb1492c3.jpg", mike_shiva.gravatar_url(:secure => true)
      assert_equal "http://0.gravatar.com/avatar/1b2818d77eadd6c9dbbe7f3beb1492c3.gif?r=x&s=16", mike_shiva.gravatar_url(:filetype => :gif, :rating => :x, :size => 16)
    end
    
    should "allow some default options to be passed, which can be overriden locally, though" do
      poro = Class.new(PoroUser) { gravatarify :secure => true, :filetype => :gif }
      mike_shiva = poro.new(:email => 'mike@shiva.ch')
      assert_equal "https://secure.gravatar.com/avatar/1b2818d77eadd6c9dbbe7f3beb1492c3.gif", mike_shiva.gravatar_url
      assert_equal "http://0.gravatar.com/avatar/1b2818d77eadd6c9dbbe7f3beb1492c3.gif", mike_shiva.gravatar_url(:secure => false)
      assert_equal "https://secure.gravatar.com/avatar/1b2818d77eadd6c9dbbe7f3beb1492c3.jpg?r=x&s=16", mike_shiva.gravatar_url(:filetype => :jpg, :rating => :x, :size => 16)      
    end
    
    should "still respect options set by Gravatarify#options" do
      Gravatarify.options[:size] = 20
      poro = Class.new(PoroUser) { gravatarify }      
      assert_equal "http://0.gravatar.com/avatar/1b2818d77eadd6c9dbbe7f3beb1492c3.jpg?s=20", poro.new(:email => 'mike@shiva.ch').gravatar_url
    end
    
    should "be able to override options set by Gravatarify#options" do
      Gravatarify.options[:size] = 20
      poro = Class.new(PoroUser) { gravatarify :size => 25 }
      assert_equal "http://0.gravatar.com/avatar/1b2818d77eadd6c9dbbe7f3beb1492c3.jpg?s=25", poro.new(:email => 'mike@shiva.ch').gravatar_url
    end    
  end
  
  context "#gravatarify with custom fields" do
    should "detect and use the 'email' field automatically" do
      poro = Class.new(PoroUser) { gravatarify }
      assert_equal "http://0.gravatar.com/avatar/1b2818d77eadd6c9dbbe7f3beb1492c3.jpg", poro.new(:email => 'mike@shiva.ch').gravatar_url
    end
    
    should "fallback to 'mail' if 'email' is not defined" do
      poro = Class.new(PoroUser) do
        gravatarify
        undef :email, :email=
        attr_accessor :mail
      end
      assert_equal "http://0.gravatar.com/avatar/1b2818d77eadd6c9dbbe7f3beb1492c3.jpg", poro.new(:mail => 'mike@shiva.ch').gravatar_url      
    end
    
    should "raise NoMethodError if object does not respond to source" do
      poro = Class.new do
        include Gravatarify::ObjectSupport
        gravatarify
      end
      assert_raise(NoMethodError) { poro.new.gravatar_url }
    end
    
    should "allow to set custom source, like author_email" do
      poro = Class.new(PoroUser) do
        gravatarify :author_email
        attr_accessor :author_email
      end
      assert_equal "http://0.gravatar.com/avatar/1b2818d77eadd6c9dbbe7f3beb1492c3.jpg", poro.new(:author_email => 'mike@shiva.ch').gravatar_url      
    end
    
    should "allow multiple sources to be defined, yet still handle options!" do
      poro = Class.new(PoroUser) do
        gravatarify :email, :employee_email, :default => Proc.new { |*args| "http://initech.com/avatar-#{args.first[:size] || 80}.jpg" }
        attr_accessor :employee_email
      end
      peter_gibbons = poro.new(:email => 'info@initech.com', :employee_email => 'peter.gibbons@initech.com')
      assert_equal "http://2.gravatar.com/avatar/4979dd9653e759c78a81d4997f56bae2.jpg?d=http%3A%2F%2Finitech.com%2Favatar-20.jpg&s=20", peter_gibbons.gravatar_url(:size => 20)
      assert_equal "http://0.gravatar.com/avatar/cb7865556d41a3d800ae7dbb31d51d54.jpg?d=http%3A%2F%2Finitech.com%2Favatar-25.jpg&s=25", peter_gibbons.employee_gravatar_url(:size => 25)
    end
    
    should "use full prefix, if not suffixed by email" do
      poro = Class.new(PoroUser) do
        gravatarify :email, :employee_login
        attr_accessor :employee_login
      end
      peter_gibbons = poro.new(:email => 'peter.gibbons@initech.com', :employee_login => 'peter.gibbons@initech.com')
      assert_respond_to peter_gibbons, :employee_login_gravatar_url
      assert_equal "http://0.gravatar.com/avatar/cb7865556d41a3d800ae7dbb31d51d54.jpg?s=25", peter_gibbons.employee_login_gravatar_url(:size => 25)      
    end
    
    should "pass in object as second parameter, not supplied string" do
      poro = Class.new(PoroUser) do
        gravatarify :default => Proc.new { |opts, obj| "http://initech.com/avatar#{obj.respond_to?(:gender) && obj.gender == :female ? '_girl' : ''}.jpg" }
      end
      peter_gibbons = poro.new(:email => 'peter.gibbons@initech.com', :gender => :male)
      jane = poro.new(:email => 'jane@initech.com', :gender => :female)
      assert_equal "http://0.gravatar.com/avatar/cb7865556d41a3d800ae7dbb31d51d54.jpg?d=http%3A%2F%2Finitech.com%2Favatar.jpg&s=25", peter_gibbons.gravatar_url(:s => 25)
      assert_equal "http://1.gravatar.com/avatar/9b78f3f45cf32d7c52d304a63f6aef06.jpg?d=http%3A%2F%2Finitech.com%2Favatar_girl.jpg&s=35", jane.gravatar_url(:s => 35)
    end
  end
end