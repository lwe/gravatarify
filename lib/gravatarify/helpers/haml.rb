module Gravatarify::Helpers::Haml
  include Gravatarify::Helpers::Simple
  
  # Helper method for HAML to return a neat hash to be used as attributes in an image tag.
  #
  # Now it's as simple as doing something like:
  #
  #    %img{ gravatar_attrs(@user.mail, :size => 20) }/
  #
  def gravatar_attrs(email, options = {})
    url_options = options.reject { |key,value| !Gravatarify::GRAVATAR_OPTIONS.include?(key) }
    options[:alt] ||= Gravatarify::Base.get_smart_email_from(email) # use email as :alt attribute
    options[:width] = options[:height] = (url_options[:size] || Gravatarify::GRAVATAR_DEFAULT_SIZE) # customize size
    options[:src] = email.respond_to?(:gravatar_url) ? email.gravatar_url(url_options) : build_gravatar_url(email, url_options)
    options
  end  
end