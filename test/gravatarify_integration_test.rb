require 'test_helper'
begin
  require 'activerecord'
rescue LoadError
  puts "INCOMPLETE - ActiveRecord not available -> 2 tests skipped"
end
begin
  require 'dm-core'
rescue LoadError
  puts "INCOMPLETE - DataMapper not available -> 2 tests skipped"
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
    context "DataMapper::Model" do
      should "include Gravatarify::ObjectSupport" do
        assert DataMapper::Model.included_modules.include?(Gravatarify::ObjectSupport)
      end
      
      should "respond to #gravatarify" do
        assert_respond_to DataMapper::Model, :gravatarify
      end
    end
  end
end
