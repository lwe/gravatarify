require 'test_helper'
require 'gravatarify/helpers/haml'

class GravatarifyHelpersTest < Test::Unit::TestCase
  include Gravatarify::Helpers::Haml  
  
  def setup
    # just ensure that no global options are defined when starting next test
    reset_gravatarify!
  end

  context "#gravatar_attrs" do
    should "return hash with :heigth, :width, :alt and :src defined" do
      hash = gravatar_attrs('bella@gmail.com', :size => 16)
      assert_equal 'http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg?s=16', hash[:src]
      assert_equal 16, hash[:width]
      assert_equal 16, hash[:height]
      assert_equal 'bella@gmail.com', hash[:alt]
    end
    
    should "allow any param to be defined/overridden, except src, width and heigth" do
      hash = gravatar_attrs('bella@gmail.com', :size => 20, :height => 40, :alt => 'bella', :id => 'test', :title => 'something', :class => 'gravatar')
      assert_equal 'http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg?s=20', hash[:src]
      assert_equal 20, hash[:width]
      assert_equal 20, hash[:height]
      assert_equal 'bella', hash[:alt]
      assert_equal 'test', hash[:id]
      assert_equal 'something', hash[:title]
      assert_equal 'gravatar', hash[:class]
    end
  end
end