require 'test_helper'

class StylesTest < Test::Unit::TestCase
  include Gravatarify::Helper
  
  def setup
    reset_gravatarify!
    Gravatarify.styles.clear
  end
  
  context "Gravatarify#styles" do
    should "allow to easily set custom styles" do
      Gravatarify.styles[:mini] = { :size => 16 }
      exp = { :size => 16 }
      assert_equal exp, Gravatarify.styles[:mini]
    end
  end
  
  context "Gravatarify::Base#gravatar_url" do
    setup { Gravatarify.styles[:mini] = { :size => 16, :default => :wavatar } }
    
    should "still work without any argument" do
      assert_equal BELLA_AT_GMAIL_JPG, gravatar_url('bella@gmail.com')      
    end
    
    should "respect styles" do
      assert_equal "#{BELLA_AT_GMAIL_JPG}?d=wavatar&s=16", gravatar_url('bella@gmail.com', :mini)
    end
    
    should "allow to override styles" do
      assert_equal "#{BELLA_AT_GMAIL}?d=404&s=16", gravatar_url('bella@gmail.com', :mini, :filetype => false, :default => 404)
    end
    
    should "override default options" do
      Gravatarify.options[:size] = 45
      assert_equal "#{BELLA_AT_GMAIL_JPG}?d=wavatar&s=16", gravatar_url('bella@gmail.com', :mini)
    end
    
    should "inherit default options" do
      Gravatarify.options[:size] = 45
      Gravatarify.options[:filetype] = 'png'
      assert_equal "#{BELLA_AT_GMAIL}.png?d=wavatar&s=16", gravatar_url('bella@gmail.com', :mini)
    end
  end
  
  context "Gravatarify::Helper#gravatar_attrs" do
    setup { Gravatarify.styles[:mini] = { :size => 16 } }
    
    should "still work as-is without options" do
      expected = { :src => BELLA_AT_GMAIL_JPG, :alt => '', :width => 80, :height => 80 }
      assert_equal expected, gravatar_attrs('bella@gmail.com')
    end
  end
end