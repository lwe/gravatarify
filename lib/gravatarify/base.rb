require 'digest/md5'
require 'cgi'

module Gravatarify
  # Hash of :ultra_long_option_name => :abbr_opt
  GRAVATAR_ABBREV_OPTIONS = { 'default' => :d, :default => :d, 'rating' => :r, :rating => :r, 'size' => :s, :size => :s }

  # Provides core support to build gravatar urls based on supplied e-mail strings.
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
    # @param [String, #email, #mail] email a string representing an email, or object which responds to +email+ or +mail+
    # @param [Symbol, Hash] *params customize generated gravatar.com url. First argument can also be a style.
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
      url_options = Utils.merge_gravatar_options(*params)
      email_hash = Digest::MD5.hexdigest(Utils.smart_email(email))
      extension = (ext = url_options.delete(:filetype) and ext != '') ? ".#{ext || 'jpg'}" : '' # slightly adapted from gudleik's implementation
      host = Base.gravatar_host(self, email_hash, url_options.delete(:secure))
      "#{host}/avatar/#{email_hash}#{extension}#{Base.gravatar_params(email, url_options)}"
    end

    # For backwards compatibility.
    alias_method :build_gravatar_url, :gravatar_url

    protected
      # Builds gravatar host name from supplied e-mail hash.
      # Ensures that for the same +str_hash+ always the same subdomain is used.
      #
      # @param [String] str_hash email, as hashed string as described in gravatar.com implementation specs
      # @param [Boolean, Proc] secure if set to +true+ then uses gravatars secure host (<tt>https://secure.gravatar.com</tt>),
      #        else that subdomain magic. If it's passed in a +Proc+, it's evaluated and the result (+true+/+false+) is used
      #        for the same decicion.
      # @return [String] Protocol and hostname (like <tt>http://www.gravatar.com</tt>), without trailing slash.
      def self.gravatar_host(context, str_hash, secure = false)
        use_https = secure.respond_to?(:call) ? secure.call(context) : secure
        "#{use_https ? 'https' : 'http'}://#{Gravatarify.subdomain(str_hash)}gravatar.com"
      end

      # Builds a query string from all passed in options.
      def self.gravatar_params(source, url_options = {})
        params = url_options.inject([]) do |params, (key, value)|
          key = (GRAVATAR_ABBREV_OPTIONS[key] || key).to_sym # shorten & symbolize key
          unless key == :html
            value = value.call(url_options, source) if key == :d && value.respond_to?(:call)
            params << "#{key}=#{CGI.escape(value.to_s)}" if value
          end
          params
        end
        "?#{params.sort * '&'}" unless params.empty?
      end
  end
end
