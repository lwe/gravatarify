require 'test_helper'
require 'gravatarify/base'

class MockView
  include Gravatarify::Base
end

class GravatarifyBaseTest < Test::Unit::TestCase
  include Gravatarify::Base
  
  def setup
    # just ensure that no global options are defined when starting next test
    Gravatarify.options.clear
  end
    
  context "#build_gravatar_url, but without any options yet" do
    should "generate correct url for hash without options" do
      assert_equal "http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg", build_gravatar_url('bella@gmail.com')
    end

    should "trim and lowercase email address (as according to gravatar docs)" do
      assert_equal "http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg", build_gravatar_url("\tbella@gmail.com \n\t")
      assert_equal "http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg", build_gravatar_url("BELLA@gmail.COM")
      assert_equal "http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg", build_gravatar_url(" BELLA@GMAIL.com")
    end

    should "handle a nil email as if it were an empty string" do
      assert_equal "http://1.gravatar.com/avatar/d41d8cd98f00b204e9800998ecf8427e.jpg", build_gravatar_url(nil)
      assert_equal "http://1.gravatar.com/avatar/d41d8cd98f00b204e9800998ecf8427e.jpg", build_gravatar_url('')
    end
  end
  
  context "#build_gravatar_url, with options" do
    should "add well known options like size, rating or default and always in alphabetical order" do
      assert_equal "http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg?s=16", build_gravatar_url('bella@gmail.com', :size => 16)
      assert_equal "http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg?d=http%3A%2F%2Fexample.com%2Ftest.jpg&s=20",
                   build_gravatar_url('bella@gmail.com', :size => 20, :default => 'http://example.com/test.jpg')
      assert_equal "http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg?other=escaped%26yes%3F&r=x&s=30",
                   build_gravatar_url('bella@gmail.com', :size => 30, :rating => :x, :other => "escaped&yes?")
    end
    
    should "ensure that all options as well as keys are escaped correctly" do
      assert_equal "http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg?escaped%2Fme=escaped%2Fme",
                   build_gravatar_url('bella@gmail.com', 'escaped/me' => 'escaped/me')
    end
    
    should "ignore false or nil options" do
      assert_equal "http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg?s=24",
                    build_gravatar_url('bella@gmail.com', :s => 24, :invalid => false, :other => nil)
    end
    
    should "allow different :filetype to be set, like 'gif' or 'png'" do
      assert_equal "http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.gif", build_gravatar_url('bella@gmail.com', :filetype => :gif)
      assert_equal "http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.png", build_gravatar_url('bella@gmail.com', :filetype => :png)
    end
  
    should "handle Procs as :default, to easily generate default urls based on supplied :size" do
      default = Proc.new { |o| "http://example.com/gravatar#{o[:size] ? '-' + o[:size].to_s : ''}.jpg" }
      assert_equal "http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg?d=http%3A%2F%2Fexample.com%2Fgravatar.jpg",
                    build_gravatar_url('bella@gmail.com', :default => default)        
      assert_equal "http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg?d=http%3A%2F%2Fexample.com%2Fgravatar-25.jpg&s=25",
                    build_gravatar_url('bella@gmail.com', :size => 25, :d => default)
      assert_equal "http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg?d=http%3A%2F%2Fexample.com%2Fgravatar-20.jpg&s=20",
                    build_gravatar_url('bella@gmail.com', :size => 20, 'd' => default)
    end    
  end
  
  context "#build_gravatar_url when passed in an object" do
    should "look for :email method and use it to generate build_gravatar_url from" do
      obj = Object.new
      mock(obj).email { "bella@gmail.com" }
      
      assert_equal "http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg", build_gravatar_url(obj)
    end
    
    should "look for :mail of field :email does not exist" do
      obj = Object.new
      mock(obj).mail { "bella@gmail.com" }
      
      assert_equal "http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg", build_gravatar_url(obj)      
    end
    
    should "finally just use to_s... if neither :email nor :mail exists" do
      obj = Object.new
      mock(obj).to_s { "bella@gmail.com" }
      
      assert_equal "http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg", build_gravatar_url(obj)      
    end
  end
  
  context "Gravatar hosts support" do
    should "switch to different hosts based on generated email hash, yet always the same for consecutive calls with the same email!" do
      assert_equal "http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg", build_gravatar_url('bella@gmail.com')
      assert_equal build_gravatar_url('bella@gmail.com'), build_gravatar_url('bella@gmail.com')
      assert_equal "http://1.gravatar.com/avatar/41d86cad3dd465d6913d5a3232744441.jpg", build_gravatar_url('bella@bella.com')
      assert_equal "http://2.gravatar.com/avatar/8f3af64e9c215d158b062a7b154e071e.jpg", build_gravatar_url('bella@hotmail.com')
      assert_equal "http://www.gravatar.com/avatar/d2279c22a33da2cb57defd21c33c8ec5.jpg", build_gravatar_url('bella@yahoo.de')
    end
    
    should "switch to https://secure.gravatar.com if :secure => true is supplied" do
      assert_equal "https://secure.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg", build_gravatar_url('bella@gmail.com', :secure => true)
      assert_equal "https://secure.gravatar.com/avatar/41d86cad3dd465d6913d5a3232744441.jpg", build_gravatar_url('bella@bella.com', :secure => true)
      assert_equal "https://secure.gravatar.com/avatar/d2279c22a33da2cb57defd21c33c8ec5.jpg", build_gravatar_url('bella@yahoo.de', :secure => true)
    end
    
    should "allow Procs for :secure option, enables pretty cool stuff for stuff like request.ssl?" do
      Gravatarify.options[:secure] = Proc.new { |obj| obj.request.ssl? }
      
      mock_ssl = MockView.new
      mock(mock_ssl).request.stub!.ssl? { true }      
      assert_equal "https://secure.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg", mock_ssl.build_gravatar_url('bella@gmail.com')
      
      mock_no_ssl = MockView.new
      mock(mock_no_ssl).request.stub!.ssl? { false }
      assert_equal "http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.jpg", mock_no_ssl.build_gravatar_url('bella@gmail.com')
    end
  end
    
  context "Gravatarify#options" do
    setup do
      Gravatarify.options[:anything] = "test"
      Gravatarify.options[:filetype] = "png"
      Gravatarify.options[:default] = "http://example.com/gravatar.jpg"
    end
    
    should "ensure that default options are always added" do
      assert_equal "http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.png?anything=test&d=http%3A%2F%2Fexample.com%2Fgravatar.jpg",
                    build_gravatar_url('bella@gmail.com')
    end
    
    should "ensure that default options can be overriden by passing options into build_gravatar_url call" do
      assert_equal "http://0.gravatar.com/avatar/1cacf1bc403efca2e7a58bcfa9574e4d.gif?anything=else&d=http%3A%2F%2Fexample.com%2Fgravatar.jpg",
                    build_gravatar_url('bella@gmail.com', :anything => "else", :filetype => :gif)
    end
  end
end
