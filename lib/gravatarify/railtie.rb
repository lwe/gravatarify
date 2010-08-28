require 'gravatarify'

module Gravatarify
  class Railtie < Rails::Railtie
    initialize 'gravatarify.extend.action_view' do
      Gravatarify.setup
    end
  end
end
