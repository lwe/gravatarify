require 'gravatarify/base'
require 'gravatarify/utils'
require 'gravatarify/helper'

module Gravatarify
  # current API version, as defined by http://semver.org/
  VERSION = "2.2.1".freeze
end

if defined?(ActiveSupport) && ActiveSupport.respond_to?(:on_load)
  # Support for rails 3
  ActiveSupport.on_load(:action_view) { include Gravatarify::Helper }
elsif defined?(ActionView)
  # hook into rails 2.x
  ActionView::Base.send(:include, Gravatarify::Helper) if defined?(ActionView)
end
# try to include it in HAML too, no matter what :)
Haml::Helpers.send(:include, Gravatarify::Helper) if defined?(Haml)
