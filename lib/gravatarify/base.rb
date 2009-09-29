require 'digest/md5'
require 'cgi'

module Gravatarify
  
  # Hosts used for balancing
  GRAVATAR_HOSTS = %w{ 0 1 2 www }
  
  # If no size is specified, gravatar.com returns 80x80px images
  GRAVATAR_DEFAULT_SIZE = 80
  
  # Default filetype is JPG
  GRAVATAR_DEFAULT_FILETYPE = 'jpg'

  # List of known and valid gravatar options (includes shortened options).
  GRAVATAR_OPTIONS = [ :default, :d, :rating, :r, :size, :s, :secure, :filetype ]

  # Hash of :ultra_long_option_name => 'abbrevated option'
  GRAVATAR_ABBREV_OPTIONS = { :default => 'd', :rating => 'r', :size => 's' }
  
  # Options which can be globally overriden by the application
  def self.options; @options ||= {} end
    
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
    # @option url_options [String, Symbol] :filetype (:jpg) Gravatar.com supports only <tt>:gif</tt>, <tt>:jpg</tt> and <tt>:png</tt>
    # @return [String] In any case (even if supplied +email+ is +nil+) returns a fully qualified gravatar.com URL.
    #                  The returned string is not yet HTML escaped, *but* all +url_options+ have been URI escaped.
    def build_gravatar_url(email, url_options = {})
      # FIXME: add symbolize_keys again, maybe just write custom method, so we do not depend on ActiveSupport magic...
      url_options = Gravatarify.options.merge(url_options)
      email_hash = Digest::MD5.hexdigest(Base.get_smart_email_from(email).strip.downcase)
      build_gravatar_host(email_hash, url_options.delete(:secure)) << "/avatar/#{email_hash}.#{url_options.delete(:filetype) || GRAVATAR_DEFAULT_FILETYPE}#{build_gravatar_options(url_options)}"
    end
  
    private
      def build_gravatar_host(str_hash, secure = false)
        secure = secure.call(respond_to?(:request) ? request : nil) if secure.respond_to?(:call)
        secure ? "https://secure.gravatar.com" : "http://#{GRAVATAR_HOSTS[str_hash.hash % GRAVATAR_HOSTS.size] || 'www'}.gravatar.com"        
      end
    
      def build_gravatar_options(url_options = {})
        params = []
        url_options.each_pair do |key, value|
          key = GRAVATAR_ABBREV_OPTIONS[key] if GRAVATAR_ABBREV_OPTIONS.include?(key) # shorten key!
          value = value.call(url_options) if key.to_s == 'd' and value.respond_to?(:call)
          params << "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}" if value
        end
        "?#{params.sort * '&'}" unless params.empty?
      end
      
      def self.get_smart_email_from(obj)
        (obj.respond_to?(:email) ? obj.email : (obj.respond_to?(:mail) ? obj.mail : obj)).to_s
      end
  end
end