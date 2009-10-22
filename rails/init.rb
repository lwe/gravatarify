require 'gravatarify'

# if HAML not yet loaded (due to load order), yet plugin exists
if !defined?(Haml) and File.exists?(Rails.root.join('vendor', 'plugins', 'haml'))
  require 'gravatarify/helpers/haml'
  ActionView::Base.send(:include, Gravatarify::Helpers::Haml)
end

# load view helpers only if ActionView is available
if defined?(ActionView)
  require 'gravatarify/helpers/rails'
  ActionView::Base.send(:include, Gravatarify::Helpers::Rails)
end