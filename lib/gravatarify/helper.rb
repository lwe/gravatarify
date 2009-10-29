module Gravatarify::Helper
  # so that it's possible to access that build_gravatar_url method
  include Gravatarify::Base
  
  # Allow HTML options to be overriden globally as well, useful
  # to e.g. define a common alt attribute, or class.
  #
  #    Gravatarify::Helper.html_options[:title] = "Gravatar"
  #
  # @return [Hash] globally defined html attributes  
  def self.html_options; @html_options ||= { :alt => '' } end
  
  # Helper method for HAML to return a neat hash to be used as attributes in an image tag.
  #
  # Now it's as simple as doing something like:
  #
  #    %img{ gravatar_attrs(@user.mail, :size => 20) }/
  #
  # This is also the base method for +gravatar_tag+.
  #
  # @param [String, #email, #mail, #gravatar_url] email a string or an object used
  #        to generate to gravatar url for.
  # @param [Hash] options other gravatar or html options for building the resulting
  #        hash.
  # @return [Hash] all html attributes required to build an +img+ tag.
  def gravatar_attrs(email, options = {})
    url_options = options.inject({}) { |hsh, (key, value)| hsh[key] = options.delete(key) if Gravatarify::GRAVATAR_OPTIONS.include?(key.to_sym); hsh }
    options[:width] = options[:height] = (url_options[:size] || 80) # customize size
    options[:src] = email.respond_to?(:gravatar_url) ? email.gravatar_url(url_options) : gravatar_url(email, url_options)
    Gravatarify::Helper.html_options.merge(options)
  end
  
  # Takes care of creating an <tt><img/></tt>-tag based on a gravatar url, it no longer
  # makes use of any Rails helper, so is totally useable in any other library.
  #
  # @param [String, #email, #mail, #gravatar_url] email a string or an object used
  #        to generate the gravatar url from
  # @param [Hash] options other gravatar or html options for building the resulting
  #        image tag.
  # @return [String] a complete and hopefully valid +img+ tag.
  def gravatar_tag(email, options = {})
    html_attrs = gravatar_attrs(email, options).map do |key,value|
      escaped = defined?(Rack::Utils) ? Rack::Utils.escape_html(value) : CGI.escapeHTML(value)
      "#{key}=\"#{escaped}\""
    end.sort.join(" ")
    "<img #{html_attrs} />"
  end
end