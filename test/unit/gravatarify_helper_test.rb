require 'test_helper'
require 'gravatarify/helper'

class GravatarifyHelpersTest < Test::Unit::TestCase
  include Gravatarify::Helper  
  
  def setup
    # just ensure that no global options are defined when starting next test
    reset_gravatarify!
  end
  
  def teardown
    Gravatarify::Helper.html_options.clear
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
      expected = { :alt => "", :src => "#{BELLA_AT_GMAIL_JPG}?s=16", :width => 16, :height => 16 }
      assert_equal expected, hash
      assert_nil hash[:size]
    end
    
    should "allow any param to be defined/overridden, except src, width and heigth" do
      hash = gravatar_attrs('bella@gmail.com', :size => 20, :r => :x, :height => 40, :alt => 'bella', :id => 'test', :title => 'something', :class => 'gravatar')
      expected = {
        :alt => 'bella', :src => "#{BELLA_AT_GMAIL_JPG}?r=x&s=20", :width => 20, :height => 20,
        :id => 'test', :title => 'something', :class => 'gravatar'
      }
      assert_equal expected, hash
      assert_nil hash[:size]
      assert_nil hash[:r]
    end
  end  
  
  context "#gravatar_tag helper" do
    should "create <img/> tag with correct gravatar urls" do
      assert_equal '<img alt="" height="80" src="http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg" width="80" />', gravatar_tag('bella@gmail.com')
    end
    
    should "create <img/> tags and handle all options correctly, other options should be passed to Rails' image_tag" do
      assert_equal '<img alt="" height="16" src="http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg?s=16" width="16" />',
              gravatar_tag('bella@gmail.com', :size => 16)
      assert_equal '<img alt="" class="gravatar" height="16" src="http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg?d=x&amp;s=16" width="16" />',
              gravatar_tag('bella@gmail.com', :class => "gravatar", :size => 16, :d => "x")
    end
    
    should "ensure that all values are correctly html-esacped!" do
      assert_equal '<img alt="" height="80" src="http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg" title="&lt;&gt;" width="80" />',
              gravatar_tag('bella@gmail.com', :title => '<>')
    end
  end
  
  context "#gravatar_tag when passed in an object" do
    should "create <img/>-tag based on :email field" do
      obj = Object.new
      mock(obj).email { "bella@gmail.com" }
      
      assert_equal '<img alt="" height="80" src="http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg" width="80" />',
                      gravatar_tag(obj)      
    end
    
    should "create <img/>-tag based on gravatar_url from object if object responds to gravatar_url" do
      obj = Object.new
      mock(obj).name { "Mr. X" }
      mock(obj).gravatar_url({ :size => 16 }) { "http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg?s=16" }
      
      assert_equal '<img alt="Gravatar for Mr. X" height="16" src="http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg?s=16" width="16" />',
                      gravatar_tag(obj, :size => 16, :alt => "Gravatar for #{obj.name}")
    end
  end
  
  context "Gravatarify::Helper#html_options" do
    should "add be added to all tags/hashes created by gravatar_tag or gravatar_attrs" do
      Gravatarify::Helper.html_options[:title] = "Gravatar" # add a title attribute, yeah neat-o!
      Gravatarify::Helper.html_options[:class] = "gravatar"
      
      assert_equal '<img alt="" class="gravatar" height="80" src="http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg" title="Gravatar" width="80" />',
                      gravatar_tag('bella@gmail.com')
      hash = gravatar_attrs('bella@gmail.com', :size => 20, :title => "Gravatar for Bella", :id => "test")
      expected = {
        :alt => "", :width => 20, :height => 20, :src => "http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg?s=20",
        :title => "Gravatar for Bella", :id => "test", :class => "gravatar"
      }
      assert_equal expected, hash
    end
  end
end