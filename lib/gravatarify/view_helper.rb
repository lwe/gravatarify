module Gravatarify::ViewHelper
  include Gravatarify::Base
  
  # Create <img .../> tag by passing +email+ to +gravatar_url+, is based
  # on rails +image_tag+ helper method.
  #
  #    <%= gravatar_tag(current_user.email, :size => 20) %>  # -> <img alt="... height="20" src="http://grava... width="20" />
  #    <%= gravatar_tag('foo@bar.com', :class => "gravatar") # -> <img alt="foo@bar.com" class="gravatar" height="80" ... width="80" />
  #
  # Note: this method tries to be very clever about which options need to be passed to
  # +gravatar_url+ and which to +image_tag+, so using this method it's not possible to
  # send arbitary attributes to +gravatar_url+ and have them included in the url.
  def gravatar_tag(email, options = {})
    url_options = options.symbolize_keys.reject { |k,v| !Gravatarify::GRAVATAR_OPTIONS.include?(k) }
    options[:alt] ||= Gravatarify::Base.get_smart_email_from(email) # use email as :alt attribute
    options[:width] = options[:height] = (url_options[:size] || Gravatarify::GRAVATAR_DEFAULT_SIZE) # customize size
    image_tag(email.respond_to?(:gravatar_url) ? email.gravatar_url(url_options) : gravatar_url(email, url_options), options)
  end
end