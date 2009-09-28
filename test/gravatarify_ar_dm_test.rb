require 'test_helper'
require 'activerecord'
require 'dm-core'
require 'gravatarify'

class GravatarifyArDmTest < Test::Unit::TestCase
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
  else
    puts "INCOMPLETE - ActiveRecord not available -> skipped"
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
  else
    puts "INCOMPLETE - DataMapper not available -> skipped"
  end
end
