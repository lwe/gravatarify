# Loads all required submodules

# Base -> provides the basic gravatar_url method, can also be used for
# custom implementations, just include Gravatarify::Base.
require 'gravatarify/base'
require 'gravatarify/view_helper'
require 'gravatarify/object_support'

# include helper for rails
ActionView::Base.send(:include, Gravatarify::ViewHelper) if defined?(ActionView)

# setup for AR und DataMapper, note: DataMapper yet untested :) but I suppose it works, because
# it works as expected on plain old ruby objects!
ActiveRecord::Base.send(:include, Gravatarify::ObjectSupport) if defined?(ActiveRecord)
DataMapper::Model.send(:include, Gravatarify::ObjectSupport) if defined?(DataMapper)