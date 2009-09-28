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
    #    gravatar_url('peter.gibbons@initech.com', :size => 16) # => "http://0.gravatar.com/avatar/cb7865556d41a3d800ae7dbb31d51d54.jpg?s=16"
    #
    # It supports multiple gravatar hosts (based on email hash), i.e. depending
    # on the hash, either <tt>0.gravatar.com</tt>, <tt>1.gravatar.com</tt>, <tt>2.gravatar.com</tt> or <tt>www.gravatar.com</tt>
    # is used.
    #
    # If supplied +email+ responds to either a method named +email+ or +mail+, the value of that method
    # is used instead to build the gravatar hash. Very useful to just pass in ActiveRecord object for instance:
    #    
    #    @user = User.find_by_email("samir@initech.com")
    #    gravatar_url(@user) # => "http://2.gravatar.com/avatar/58cf31c817d76605d5180ce1a550d0d0.jpg"
    #    gravatar_url(@user.email) # same as above!
    # 
    # Among all options as defined by gravatar.com's specification, there also exist some special options:
    #
    #    gravatar_url(@user, :secure => true) # => https://secure.gravatar.com/ava....
    #
    # Useful when working on SSL enabled sites. Of course often used options should be set through
    # +Gravatarify.options+.
    #
    # == List of options:
    # * <tt>:default</tt> - +Proc+ or string - URL of an image to use as default when no gravatar exists for that
    #   url. Gravatar.com also accepts special values like +identicon+, +monsterid+ or +wavatar+ which just displays
    #   a generic icon based on the hash or the <tt>404</tt> which returns a HTTP Status 404 error page.
    # * <tt>:rating</tt> - string or symbol - Define the rating, gravatar.com supports <tt>:g</tt> (default),
    #   <tt>:pg</tt>, <tt>:r</tt> or <tt>:x</tt>.
    # * <tt>:size</tt> - integer - Size of the image, images are square (default, as defined by gravatar.com is 80).
    # * <tt>:secure</tt> - boolean - If set to +true+, then the secure gravatar.com url is used, else the host
    #   is inflected based on the hash of the md5 (Default: +false+)
    # * <tt>:filetype</tt> - string or symbol - Gravatar.com currently only supports +:jpg+, +:gif+ and +:png+
    #   (Default is: +:jpg+)    
    def gravatar_url(email, url_options = {})
      # FIXME: add symbolize_keys again, maybe just write custom method, so we do not depend on ActiveSupport magic...
      url_options = Gravatarify.options.merge(url_options)
      email_hash = Digest::MD5.hexdigest(Base.get_smart_email_from(email).strip.downcase)
      build_gravatar_host(email_hash, url_options.delete(:secure)) << "/avatar/#{email_hash}.#{url_options.delete(:filetype) || GRAVATAR_DEFAULT_FILETYPE}#{build_gravatar_options(url_options)}"
    end
    # Ensure that default implementation is always available through +base_gravatar_url+.
    alias_method :base_gravatar_url, :gravatar_url
  
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