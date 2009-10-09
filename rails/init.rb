require 'gravatarify'

# load view helpers only if ActionView is available
if defined?(ActionView)
  require 'gravatarify/view_helper'
  ActionView::Base.send(:include, Gravatarify::ViewHelper)
end
