require 'gravatarify'
require 'rails'

module Gravatarify
  class Railtie < Rails::Railtie
    initialize 'gravatarify.extend.action_view' do
      Rails.logger.error "[Gravatarify::Railtie] initialize('gravatarify.extend.action_view')"
      ActiveSupport.on_load(:action_view) do
        Rails.logger.error "[Gravatarify::Railtie] ActiveSupport.on_load(:action_view), #{self.class}"
        include Gravatarify::Helper
      end
    end
  end
end
