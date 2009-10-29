require 'digest/md5'
begin; require 'rack/utils'; rescue LoadError; require 'cgi' end

module Gravatarify  
  # List of known and valid gravatar options (includes shortened options).
  GRAVATAR_OPTIONS = [ :default, :d, :rating, :r, :size, :s, :secure, :filetype ]

  # Hash of :ultra_long_option_name => 'abbrevated option'
  GRAVATAR_ABBREV_OPTIONS = { :default => 'd', :rating => 'r', :size => 's' }
  
  class << self
    # Globally define options which are then merged on every call to
    # +build_gravatar_url+, this is useful to e.g. define the default image.
    #
    # Setting global options should be done (for Rails apps) in an initializer:
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
  
    # Allows to do stuff like default options.
    def styles; @styles ||= Hash.new({}) end
    
    # Globally overide subdomains used to build gravatar urls, normally
    # +gravatarify+ picks from either +0.gravatar.com+, +1.gravatar.com+,
    # +2.gravatar.com+ or +www.gravatar.com+ when building hosts, to use a custom
    # set of subdomains (or none!) do something like:
    #
    #     Gravatarify.subdomains = %w{ 0 www } # only use 0.gravatar.com and www.gravatar.com
    #
    #     Gravatarify.subdomain = 'www' # only use www! (PS: subdomain= is an alias)
    #
    def subdomains=(subdomains) @subdomains = [*subdomains] end
    alias_method :subdomain=, :subdomains=
    
    # Shortcut method to reset subdomains to only build +www.gravatar.com+ urls,
    # i.e. disable host balancing!
    def use_www_only!; self.subdomains = %w{ www } end

    # Access currently defined subdomains, defaults are +%w{ 0 1 2 www }+.
    def subdomains; @subdomains ||= %w{ 0 1 2 www } end
    
    # Get subdomain for supplied string or returns +www+ if none is
    # defined.
    def subdomain(str); subdomains[str.hash % subdomains.size] || 'www' end
    
    # Helper method to URI escape a string using either <tt>Rack::Utils#escape</tt> if available or else
    # fallback to <tt>CGI#escape</tt>.
    def escape(str) #:nodoc:
      str = str.to_s unless str.is_a?(String) # convert to string!
      defined?(Rack::Utils) ? Rack::Utils.escape(str) : CGI.escape(str)
    end
  end
  
  # Provides core support to build gravatar urls based on supplied e-mail strings.
  module Base
    
    # Method which builds a gravatar url based on a supplied email and options as
    # defined by gravatar.com (http://en.gravatar.com/site/implement/url).
    #
    #    build_gravatar_url('peter.gibbons@initech.com', :size => 16) # => "http://0.gravatar.com/avatar/cb7865556d41a3d800ae7dbb31d51d54.jpg?s=16"
    #
    # It supports multiple gravatar hosts (based on email hash), i.e. depending
    # on the hash, either <tt>0.gravatar.com</tt>, <tt>1.gravatar.com</tt>, <tt>2.gravatar.com</tt> or <tt>www.gravatar.com</tt>
    # is used.
    #
    # If supplied +email+ responds to either a method named +email+ or +mail+, the value of that method
    # is used instead to build the gravatar hash. Very useful to just pass in ActiveRecord object for instance:
    #    
    #    @user = User.find_by_email("samir@initech.com")
    #    build_gravatar_url(@user) # => "http://2.gravatar.com/avatar/58cf31c817d76605d5180ce1a550d0d0.jpg"
    #    build_gravatar_url(@user.email) # same as above!
    # 
    # Among all options as defined by gravatar.com's specification, there also exist some special options:
    #
    #    build_gravatar_url(@user, :secure => true) # => https://secure.gravatar.com/ava....
    #
    # Useful when working on SSL enabled sites. Of course often used options should be set through
    # +Gravatarify.options+.
    #
    # @param [String, #email, #mail] email a string representing an email, or object which responds to +email+ or +mail+
    # @param [Hash] url_options customize generated gravatar.com url
    # @option url_options [String, Proc] :default (nil) URL of an image to use as default when no gravatar exists. Gravatar.com
    #                                    also accepts special values like +identicon+, +monsterid+ or +wavater+ which just displays
    #                                    a generic icon based on the hash or <tt>404</tt> which return a HTTP Status 404.
    # @option url_options [String, Symbol] :rating (:g) Specify the rating, gravatar.com supports <tt>:g</tt>, <tt>:pg</tt>,
    #                                     <tt>:r</tt> or <tt>:x</tt>, they correspond to movie ratings :)
    # @option url_options [Integer] :size (80) The size of the (square) image.
    # @option url_options [Boolean, Proc] :secure (false) If set to +true+, then uses the secure gravatar.com URL. If a Proc is
    #                                     supplied it's evaluated, the Proc should evaluate to +true+ or +false+.
    # @option url_options [String, Symbol] :filetype (:jpg) Gravatar.com supports only <tt>:gif</tt>, <tt>:jpg</tt> and <tt>:png</tt>.
    #                                      if an set to +false+, +nil+ or an empty string no extension is added.
    # @return [String] In any case (even if supplied +email+ is +nil+) returns a fully qualified gravatar.com URL.
    #                  The returned string is not yet HTML escaped, *but* all +url_options+ have been URI escaped.
    def gravatar_url(email, *params)
      url_options = merge_gravatar_options(*params)
      email_hash = Digest::MD5.hexdigest(Base.get_smart_email_from(email).strip.downcase)
      extension = (ext = url_options.delete(:filetype) and ext != '') ? ".#{ext || 'jpg'}" : '' # slightly adapted from gudleik's implementation
      build_gravatar_host(email_hash, url_options.delete(:secure)) << "/avatar/#{email_hash}#{extension}#{build_gravatar_options(email, url_options)}"
    end
    alias_method :build_gravatar_url, :gravatar_url
  
    private
      # Builds gravatar host name from supplied e-mail hash.
      # Ensures that for the same +str_hash+ always the same subdomain is used.
      #
      # @param [String] str_hash email, as hashed string as described in gravatar.com implementation specs
      # @param [Boolean, Proc] secure if set to +true+ then uses gravatars secure host (<tt>https://secure.gravatar.com</tt>),
      #        else that subdomain magic. If it's passed in a +Proc+, it's evaluated and the result (+true+/+false+) is used
      #        for the same decicion.
      # @return [String] Protocol and hostname (like <tt>http://www.gravatar.com</tt>), without trailing slash.
      def build_gravatar_host(str_hash, secure = false)
        secure = secure.call(self) if secure.respond_to?(:call)
        secure ? "https://secure.gravatar.com" : "http://#{Gravatarify.subdomain(str_hash)}.gravatar.com"        
      end
      
      def merge_gravatar_options(*params)
        options = Gravatarify.options.dup
        options.merge!(Gravatarify.styles[params.shift]) unless params[0].is_a?(Hash)
        options.merge!(*params) if params.size > 0
        options
      end
    
      # Builds a query string from all passed in options.
      def build_gravatar_options(source, url_options = {})
        params = []
        url_options.each_pair do |key, value|
          key = GRAVATAR_ABBREV_OPTIONS[key] if GRAVATAR_ABBREV_OPTIONS.include?(key) # shorten key!
          value = value.call(url_options, source.is_a?(String) ? self : source) if key.to_s == 'd' and value.respond_to?(:call)
          params << "#{Gravatarify.escape(key)}=#{Gravatarify.escape(value)}" if value
        end
        "?#{params.sort * '&'}" unless params.empty?
      end
      
      # Tries first to call +email+, then +mail+ then +to_s+ on supplied
      # object.
      def self.get_smart_email_from(obj) #:nodoc:
        (obj.respond_to?(:email) ? obj.email : (obj.respond_to?(:mail) ? obj.mail : obj)).to_s
      end
  end
end