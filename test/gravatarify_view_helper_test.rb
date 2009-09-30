require 'test_helper'
require 'active_support'
require 'action_view/helpers'
require 'gravatarify/view_helper'

class GravatarifyViewHelperTest < Test::Unit::TestCase
  include ActionView::Helpers
  include Gravatarify::ViewHelper  
  
  def setup
    # just ensure that no global options are defined when starting next test
    reset_gravatarify!
  end
  
  context "#gravatar_tag helper" do
    should "create <img/> tag with correct gravatar urls" do
      assert_equal '<img alt="bella@gmail.com" height="80" src="http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg" width="80" />',
                      gravatar_tag('bella@gmail.com')
    end
    
    should "create <img/> tags and handle all options correctly, other options should be passed to Rails' image_tag" do
      assert_equal '<img alt="bella@gmail.com" height="16" src="http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg?s=16" width="16" />',
              gravatar_tag('bella@gmail.com', :size => 16)
      assert_equal '<img alt="bella@gmail.com" class="gravatar" height="16" src="http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg?s=16" width="16" />',
              gravatar_tag('bella@gmail.com', :class => "gravatar", :size => 16)
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