require 'test_helper'
require 'gravatarify/helper'

class GravatarifyHelpersTest < Test::Unit::TestCase
  include Gravatarify::Helper  
  
  def setup
    # just ensure that no global options are defined when starting next test
    reset_gravatarify!
  end

  context "#gravatar_url" do
    should "return same urls as build_gravatar_url" do
      assert_equal BELLA_AT_GMAIL_JPG, gravatar_url('bella@gmail.com')
      assert_equal "#{BELLA_AT_GMAIL_JPG}?d=x&s=16", gravatar_url('bella@gmail.com', :d => 'x', :s => 16)      
    end
  end
  
  context "#gravatar_attrs" do
    should "return hash with :height, :width, :alt and :src defined" do
      hash = gravatar_attrs('bella@gmail.com', :size => 16)
      assert_equal "#{BELLA_AT_GMAIL_JPG}?s=16", hash[:src]
      assert_equal 16, hash[:width]
      assert_equal 16, hash[:height]
      assert_equal 'bella@gmail.com', hash[:alt]
      assert_nil hash[:size]
    end
    
    should "allow any param to be defined/overridden, except src, width and heigth" do
      hash = gravatar_attrs('bella@gmail.com', :size => 20, :r => :x, :height => 40, :alt => 'bella', :id => 'test', :title => 'something', :class => 'gravatar')
      assert_equal "#{BELLA_AT_GMAIL_JPG}?r=x&s=20", hash[:src]
      assert_equal 20, hash[:width]
      assert_equal 20, hash[:height]
      assert_equal 'bella', hash[:alt]
      assert_equal 'test', hash[:id]
      assert_equal 'something', hash[:title]
      assert_equal 'gravatar', hash[:class]
      assert_nil hash[:size]
      assert_nil hash[:r]
    end
  end  
  
  context "#gravatar_tag helper" do
    should "create <img/> tag with correct gravatar urls" do
      assert_equal '<img alt="bella@gmail.com" height="80" src="http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg" width="80" />', gravatar_tag('bella@gmail.com')
    end
    
    should "create <img/> tags and handle all options correctly, other options should be passed to Rails' image_tag" do
      assert_equal '<img alt="bella@gmail.com" height="16" src="http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg?s=16" width="16" />',
              gravatar_tag('bella@gmail.com', :size => 16)
      assert_equal '<img alt="bella@gmail.com" class="gravatar" height="16" src="http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg?d=x&amp;s=16" width="16" />',
              gravatar_tag('bella@gmail.com', :class => "gravatar", :size => 16, :d => "x")
    end
    
    should "ensure that all values are correctly html-esacped!" do
      assert_equal '<img alt="bella@gmail.com" height="80" src="http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg" title="&lt;&gt;" width="80" />',
              gravatar_tag('bella@gmail.com', :title => '<>')
    end
  end
  
  context "#gravatar_tag when passed in an object" do
    should "create <img/>-tag based on :email field" do
      obj = Object.new
      mock(obj).email.times(2) { "bella@gmail.com" }
      
      assert_equal '<img alt="bella@gmail.com" height="80" src="http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg" width="80" />',
                      gravatar_tag(obj)      
    end
    
    should "create <img/>-tag based on gravatar_url from object if object responds to gravatar_url" do
      obj = Object.new
      mock(obj).gravatar_url({ :size => 16 }) { "http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg?s=16" }
      
      assert_equal '<img alt="Gravatar" height="16" src="http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg?s=16" width="16" />',
                      gravatar_tag(obj, :size => 16, :alt => "Gravatar")
    end
  end  
end