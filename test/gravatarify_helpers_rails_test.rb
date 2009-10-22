require 'test_helper'
require 'active_support'
require 'action_view'
require 'action_view/helpers'

require File.join(File.dirname(__FILE__), '..', 'rails', 'init')

class RailsMockView < ActionView::Base
  include ActionView::Helpers
end

class GravatarifyHelpersRailsTest < Test::Unit::TestCase  
  def setup
    # just ensure that no global options are defined when starting next test
    reset_gravatarify!
    @view = RailsMockView.new
  end
  
  context "#gravatar_tag helper" do
    should "create <img/> tag with correct gravatar urls" do
      assert_equal '<img alt="bella@gmail.com" height="80" src="http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg" width="80" />',
                      @view.gravatar_tag('bella@gmail.com')
    end
    
    should "create <img/> tags and handle all options correctly, other options should be passed to Rails' image_tag" do
      assert_equal '<img alt="bella@gmail.com" height="16" src="http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg?s=16" width="16" />',
              @view.gravatar_tag('bella@gmail.com', :size => 16)
      assert_equal '<img alt="bella@gmail.com" class="gravatar" height="16" src="http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg?s=16" width="16" />',
              @view.gravatar_tag('bella@gmail.com', :class => "gravatar", :size => 16)
    end
  end
  
  context "#gravatar_tag when passed in an object" do
    should "create <img/>-tag based on :email field" do
      obj = Object.new
      mock(obj).email.times(2) { "bella@gmail.com" }
      
      assert_equal '<img alt="bella@gmail.com" height="80" src="http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg" width="80" />',
                      @view.gravatar_tag(obj)      
    end
    
    should "create <img/>-tag based on gravatar_url from object if object responds to gravatar_url" do
      obj = Object.new
      mock(obj).gravatar_url({ :size => 16 }) { "http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg?s=16" }
      
      assert_equal '<img alt="Gravatar" height="16" src="http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg?s=16" width="16" />',
                      @view.gravatar_tag(obj, :size => 16, :alt => "Gravatar")
    end
  end
  
  context "ActionView::Base" do
    should "now respond_to #gravatar_url as well" do
      assert_respond_to @view, :gravatar_url
      assert_equal 'http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg', @view.gravatar_url('bella@gmail.com')
    end
  end
end