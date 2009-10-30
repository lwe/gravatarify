begin; require 'rack/utils'; rescue LoadError; require 'cgi' end

module Gravatarify
  module Utils
    class << self #:nodoc:
            
      # Helper method to URI escape a string using either <tt>Rack::Utils#escape</tt> if available or else
      # fallback to <tt>CGI#escape</tt>.
      def escape(str)
        str = str.to_s
        defined?(Rack::Utils) ? Rack::Utils.escape(str) : CGI.escape(str)
      end
      
      # Escape HTML entities in string, basically falls back to either <tt>RackUtils#escape_html</tt>
      # or <tt>CGI#escapeHTML</tt>.
      def escape_html(str)
        str = str.to_s
        defined?(Rack::Utils) ? Rack::Utils.escape_html(str) : CGI.escapeHTML(str)
      end
      
      # Merge supplied list of +params+ with the globally defined default options and
      # any params. Then merge remaining params as hash.
      # 
      def merge_gravatar_options(*params)
        return (params[1] || {}) if params.first == false
        options = Gravatarify.options.dup
        deep_merge_html!(options, Gravatarify.styles[params.shift] || {}) unless params.first.is_a?(Hash)
        deep_merge_html!(options, params.first) unless params.empty?
        options
      end
      
      def deep_merge_html!(hash, to_merge)
        html = (hash[:html] || {}).merge(to_merge[:html] || {})
        hash.merge!(to_merge)
        hash[:html] = html unless html.empty?
      end
    
      # Tries first to call +email+, then +mail+ then +to_s+ on supplied
      # object.
      def smart_email(obj)
        (obj.respond_to?(:email) ? obj.send(:email) : (obj.respond_to?(:mail) ? obj.send(:mail) : obj)).to_s.strip.downcase
      end
    end
  end
end