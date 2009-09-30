require 'test_helper'
begin; require 'activerecord'; rescue LoadError; end
begin; require 'dm-core'; rescue LoadError; end
require 'gravatarify'

class GravatarifyIntegrationTest < Test::Unit::TestCase
  def setup; reset_gravatarify! end

  context "ActiveRecord::Base" do
    if defined?(ActiveRecord)    
      should "include Gravatarify::ObjectSupport" do
        assert ActiveRecord::Base.included_modules.include?(Gravatarify::ObjectSupport)
      end
    
      should "respond to #gravatarify" do
        assert_respond_to ActiveRecord::Base, :gravatarify
      end
    else
      context "tests" do
        should "be run (but looks like ActiveRecord is not available)" do
          flunk "ActiveRecord not available -> thus tests are incomplete (error can be ignored though!)"          
        end
      end      
    end
  end
  
  context "DataMapper model (User)" do      
    if defined?(DataMapper)             
      setup do
        class User
          include DataMapper::Resource
          property :id, Serial
          property :name, String
          property :email, String
          property :author_email, String
          
          gravatarify
        end
      end
      
      should "include Gravatarify::ObjectSupport" do
        assert User.included_modules.include?(Gravatarify::ObjectSupport)
      end
      
      should "respond to #gravatarify" do
        assert_respond_to User, :gravatarify
      end
      
      context "as instance" do
        should "be able to build correct gravatar_url's!" do
          u = User.new(:email => "peter.gibbons@initech.com")
          assert_equal "http://0.gravatar.com/avatar/cb7865556d41a3d800ae7dbb31d51d54.jpg", u.gravatar_url
        end
      end
    else
      context "tests" do
        should "be run (but looks like DataMapper is not available)" do
          flunk "DataMapper not available -> thus tests are incomplete (error can be ignored though!)"
        end
      end
    end
  end
end
