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
else
  # try to hook into HAML and ActionView
  Haml::Helpers.send(:include, Gravatarify::Helper) if defined?(Haml)
  ActionView::Base.send(:include, Gravatarify::Helper) if defined?(ActionView)
end
