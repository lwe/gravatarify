# Enables +gravatarify+ support in any plain old ruby object, ActiveRecord, DataMapper or wherever you like :)
#
# Provides the {ClassMethods#gravatarify} method to handle the creation of
# a +gravatar_url+ method for a ruby object.
#
# An ActiveRecord example:
# 
#    class User < ActiveRecord::Base
#      gravatarify
#    end
#    @user.gravatar_url # that's it!
#
# A DataMapper example:
#
#    class User
#      include DataMapper::Resource
#      property ...
#      property :author_email, String
#      gravatarify :author_email
#    end
#    @user.gravatar_url # that's it, using the specified field!
#
# And finally, using a plain old ruby object:
#
#    class SimpleUser
#      include Gravatarify::ObjectSupport
#      attr_accessor :email
#      gravatarify
#    end
#    @user.gravatar_url # that's it!!!
#
# If more fine grained controller is required, feel free to use {Gravatarify::Base#build_gravatar_url}
# directly.
module Gravatarify::ObjectSupport
  include Gravatarify::Base
  
  def self.included(base) #:nodoc:
    base.send :extend, ClassMethods
  end
  
  module ClassMethods    
    def gravatarify(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      source = args.shift
      define_method(:gravatar_url) do |*params|
        source = :email if !source and respond_to?(:email)
        source = :mail if !source and respond_to?(:mail)
        build_gravatar_url send(source || :email), options.merge(params.first || {})
      end
      # has more
      args.each do |src|
        method = "#{src}_gravatar_url".sub(/_e?mail/, '')
        define_method(method) do |*params|
          build_gravatar_url send(src), options.merge(params.first || {})
        end
      end
    end
  end
end