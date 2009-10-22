module Gravatarify::Helpers
  
  # Generic view helper, which well, just aliases
  # +build_gravatar_url+ to +gravatar_url+.
  #
  # Please not that results from +gravatar_url+ are
  # *not* HTML escaped, so they must escaped manually.
  module Simple
    include Gravatarify::Base
    alias_method :gravatar_url, :build_gravatar_url
  end
end

# setup and load HAML helper if defined
if defined?(Haml)
  require 'gravatarify/helpers/haml'
  Haml::Helpers.send(:include, Gravatarify::Helpers::Haml)
end

# load view helpers only if ActionView is available
if defined?(ActionView)
  require 'gravatarify/helpers/rails'
  ActionView::Base.send(:include, Gravatarify::Helpers::Rails)
end
