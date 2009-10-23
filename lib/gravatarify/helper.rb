module Gravatarify::Helper
  # so that it's possible to access that build_gravatar_url method
  include Gravatarify::Base
  
  # to simplify things a bit and have a neat-o naming
  alias_method :gravatar_url, :build_gravatar_url
  
  # Helper method for HAML to return a neat hash to be used as attributes in an image tag.
  #
  # Now it's as simple as doing something like:
  #
  #    %img{ gravatar_attrs(@user.mail, :size => 20) }/
  #
  # This is also the base method for +gravatar_tag+.
  def gravatar_attrs(email, options = {})
    url_options = options.inject({}) { |hsh, (key, value)| hsh[key] = options.delete(key) if Gravatarify::GRAVATAR_OPTIONS.include?(key.to_sym); hsh }
    options[:alt] ||= Gravatarify::Base.get_smart_email_from(email) # use email as :alt attribute
    options[:width] = options[:height] = (url_options[:size] || 80) # customize size
    options[:src] = email.respond_to?(:gravatar_url) ? email.gravatar_url(url_options) : build_gravatar_url(email, url_options)
    options
  end
  
  # Takes care of creating an <tt><img/></tt>-tag based on a gravatar url, it no longer
  # makes use of any Rails helper, so is totally useable in any other library.
  def gravatar_tag(email, options = {})
    html_attrs = gravatar_attrs(email, options).map do |key,value|
      escaped = defined?(Rack::Utils) ? Rack::Utils.escape_html(value) : CGI.escapeHTML(value)
      "#{key}=\"#{escaped}\""
    end.sort.join(" ")
    "<img #{html_attrs} />"
  end
end