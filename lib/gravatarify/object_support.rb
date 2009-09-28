# Enables +gravatarify+ support in any _plain old ruby object_, or ActiveRecord or wherever...
module Gravatarify::ObjectSupport
  include Gravatarify::Base
  
  def self.included(base)
    base.send :extend, ClassMethods
  end
  
  module ClassMethods    
    def gravatarify(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      source = args.shift
      define_method(:gravatar_url) do |*params|
        source = :email if !source and respond_to?(:email)
        source = :mail if !source and respond_to?(:mail)
        base_gravatar_url send(source || :email), options.merge(params.first || {})
      end
      # has more
      args.each do |src|
        method = "#{src}_gravatar_url".sub(/_e?mail/, '')
        define_method(method) do |*params|
          base_gravatar_url send(src), options.merge(params.first || {})
        end
      end
    end
  end
end