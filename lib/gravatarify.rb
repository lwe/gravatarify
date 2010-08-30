# Loads all required submodules
module Gravatarify
  # current API version, as defined by http://semver.org/
  VERSION = "2.2.0".freeze
  
  autoload :Base,   'gravatarify/base'
  autoload :Utils,  'gravatarify/utils'
  autoload :Helper, 'gravatarify/helper'
  
  def self.setup
    Rails.logger.error "[Gravatarify#setup] HAML=#{defined?(Haml) ? 'yes' : 'no'}, ActionView=#{defined?(ActionView) ? 'yes' : 'no'}"
        
    # try to hook into HAML and ActionView
    Haml::Helpers.send(:include, Gravatarify::Helper) if defined?(Haml)
    ActionView::Base.send(:include, Gravatarify::Helper) if defined?(ActionView)    
  end
end