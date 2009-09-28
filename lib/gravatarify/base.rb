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
        secure ? "https://secure.gravatar.com" : "http://#{GRAVATAR_HOSTS[str_hash.hash % GRAVATAR_HOSTS.size]}.gravatar.com"        
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