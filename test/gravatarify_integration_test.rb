require 'test_helper'
begin
  require 'activerecord'
rescue LoadError
  puts "INCOMPLETE - ActiveRecord not available -> 2 tests skipped"
end
begin
  require 'dm-core'
rescue LoadError
  puts "INCOMPLETE - DataMapper not available -> 3 tests skipped"
end
require 'gravatarify'

class GravatarifyIntegrationTest < Test::Unit::TestCase
  def setup; Gravatarify.options.clear end

  if defined?(ActiveRecord)
    context "ActiveRecord::Base" do
      should "include Gravatarify::ObjectSupport" do
        assert ActiveRecord::Base.included_modules.include?(Gravatarify::ObjectSupport)
      end
    
      should "respond to #gravatarify" do
        assert_respond_to ActiveRecord::Base, :gravatarify
      end
    end
  end
  
  if defined?(DataMapper)        
    context "DataMapper model (User)" do      
      setup do
        DataMapper.setup(:default, 'sqlite3::memory:')

        class User
          include DataMapper::Resource
          property :id, Serial
          property :name, String
          property :email, String
          property :author_email, String
          
          gravatarify
        end

        DataMapper.auto_migrate!               
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
    end
  end
end
