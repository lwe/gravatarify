require 'gravatarify'
require 'rails'

module Gravatarify
  class Railtie < Rails::Railtie
    initialize 'gravatarify.extend.action_view' do
      ActiveSupport.on_load(:action_view) do
        Gravatarify.setup
      end
    end
  end
end
