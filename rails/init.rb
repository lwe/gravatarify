require 'gravatarify'

# load view helpers only if ActionView is available
if defined?(ActionView)
  require 'gravatarify/helpers/rails'
  ActionView::Base.send(:include, Gravatarify::Helpers::Rails)
end
