require 'gravatarify'

# if HAML not yet loaded (due to load order), yet plugin exists
if !defined?(Haml) and Rails.root.join('vendor', 'plugins', 'haml').exists?
  require 'gravatarify/helpers/haml'
  ActionView::Base.send(:include, Gravatarify::Helpers::Haml)
end

# load view helpers only if ActionView is available
if defined?(ActionView)
  require 'gravatarify/helpers/rails'
  ActionView::Base.send(:include, Gravatarify::Helpers::Rails)
end