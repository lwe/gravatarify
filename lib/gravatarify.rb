# Loads all required submodules

# Base -> provides the basic gravatar_url method, can also be used for
# custom implementations, just include Gravatarify::Base.
require 'gravatarify/base'
require 'gravatarify/utils'
require 'gravatarify/helper'

# and HAML support (if defined)
Haml::Helpers.send(:include, Gravatarify::Helper) if defined?(Haml)
