require 'gravatarify/version'
require 'zlib'

# Provides support for adding gravatar images in ruby (and rails)
# applications.
module Gravatarify
  autoload :Base,   'gravatarify/base'
  autoload :Helper, 'gravatarify/helper'
  autoload :Utils,  'gravatarify/utils'

  class << self

    # Global options which are merged on every call to
    # +gravatar_url+, this is useful to e.g. define a default image.
    #
    # When using Rails defining default options is best done in an
    # initializer +config/initializers/gravatarify.rb+ (or similar).
    #
    # Usage examples:
    #
    #     # set the default image using a Proc
    #     Gravatarify.options[:default] = Proc.new { |*args| "http://example.com/avatar-#{args.first[:size] || 80}.jpg" }
    #
    #     # or set a custom default rating
    #     Gravatarify.options[:rating] = :R
    #
    #     # or disable adding an extension
    #     Gravatarify.options[:filetype] = false
    #
    def options; @options ||= { :filetype => :jpg } end

    # Allows to define some styles, makes it simpler to call by name, instead of always giving a size etc.
    #
    #   Gravatarify.styles[:mini] => { :size => 30, :default => "http://example.com/gravatar-mini.jpg" }
    #
    #   # in the views, it will then use the stuff defined by styles[:mini]:
    #   <%= gravatar_tag @user, :mini %>
    #
    def styles; @styles ||= {} end

    # Globally overide subdomains used to build gravatar urls, normally
    # +gravatarify+ picks from either +0.gravatar.com+, +1.gravatar.com+,
    # +2.gravatar.com+, +3.gravater.com+ or +www.gravatar.com+ when building hosts, to use a custom
    # set of subdomains (or none!) do something like:
    #
    #     Gravatarify.subdomains = %w{ 0 www } # only use 0.gravatar.com and www.gravatar.com
    #
    def subdomains=(subdomains) @subdomains = [*subdomains] end

    # Get subdomain for supplied string or returns +www+ if none is
    # defined.
    def subdomain(str) #:nodoc:
      @subdomains ||= []
      unless @subdomains.empty?
        subdomain = @subdomains[Zlib.crc32(str) % @subdomains.size]
        subdomain + "." if subdomain
      end
    end

    # Is running rails and at least rails 3.x
    def rails?
      defined?(::Rails) && ::Rails.version.to_i >= 3
    end

    # Loads `Gravatarify::Helper` as view helper via `ActionController::Base.helper`
    def setup_rails!
      ActiveSupport.on_load(:action_controller) { ActionController::Base.helper(Gravatarify::Helper) }
    end
  end
end

# Try to init rails
Gravatarify.setup_rails! if Gravatarify.rails?
