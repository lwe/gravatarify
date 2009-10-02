# Gravatarify
    
Removes any hassles building those pesky gravatar urls, it's not there arent any alternatives [out](http://github.com/mdeering/gravitar_image_tag),
[there](http://github.com/chrislloyd/gravtastic), but none seem to support stuff like `Proc`s for the default picture url, or
the multiple host names supported by gravatar.com (great when displaying lots of avatars).

And it integrates seamlessly with Rails, Merb and even plain old Ruby.

- **Source**: [http://github.com/lwe/gravatarify](http://github.com/lwe/gravatarify)
- **Docs**:   [http://rdoc.info/projects/lwe/gravatarify](http://rdoc.info/projects/lwe/gravatarify)
- **Gem**:    [http://gemcutter.org/gems/gravatarify](http://gemcutter.org/gems/gravatarify)

## Install

Just install the gem (ensure you have gemcutter in your sources!)

    [sudo] gem install gravatarify
   
Ready to go! Using Rails? Either add as gem (in `config/environment.rb`):

    config.gem 'gravatarify', :source => 'http://gemcutter.org'
    
or install as Rails plugin:

    ./script/plugin install git://github.com/lwe/gravatarify.git
    
Of course it's also possible to just add the library onto the `$LOAD_PATH`
and then `require 'gravatarify'` it.

# Usage

This library provides...

 * ...object/model helpers, so that an object responds to `gravatar_url`, see [using the model helpers](#l_model_helpers).
   Works also very well with plain old ruby objects.
 * ...Rails view helpers, namely `gravatar_url` and `gravatar_tag`, see [using the view helpers](#l_view_helpers). This is rails only though!
 * ...and finally, a base module which provides the gravatar url generation, ready to be integrated into
   custom helpers, plain ruby code or whatever, see [back to the roots](#l_roots)

<a id="l_view_helpers"></a>
## Using the view helpers (Rails only!)

Probably one of the easiest ways to add support for gravatar images is with the included view helpers:

    <%= gravatar_tag @user %> # assumes @user has email or mail field!

This builds a neat `<img/>`-tag, if you need to pass in stuff like the size etc. just:

    <%= gravatar_tag @user, :size => 25, :rating => :x, :class => "gravatar" %>

This will display an "X" rated avatar which is 25x25 pixel in size and the image tag will have the class `"gravatar"`.
If more control is required, or just the URL, well then go ahead and use `gravatar_url` instead:

    <%= image_tag gravatar_url(@user.author_email, :size => 16), :size => "16x16",
         :alt => @user.name, :class => "avatar avatar-16"}/

Using rails `image_tag` to create an `<img/>`-tag with `gravatar_url`. It's important to know that 
also an object can be passed to `gravatar_url`, if it responds to either `email` or `mail`. If not (like
in the example above), the email address must be passed in.

<a id="l_model_helpers"/>
## Using the model helpers

A very simple method to add `gravatar_url` support to models is by using the `gravatarify` class method.

    class User < ActiveRecord::Base
     gravatarify
    end
   
Thats it! Well, at least if the `User` model responds to `email` or `mail`. Then in the views all left to do is:

    <%= image_tag @user.gravatar_url %>
   
Neat, isn't it? Of course passing options works just like with the view helpers:

    <%= image_tag @user.gravatar_url(:size => 16, :rating => :r) %>
   
Defaults can even be passed to the `gravatarify` call, so no need to repeat them on every `gravatar_url` call.

    gravatarify :employee_mail, :size => 16, :rating => :r
   
All gravatars will now come from the `employee_mail` field, not the default `email` or `mail` field and be in 16x16px in size
and have a rating of 'r'. Of course these can be overriden in calls to `gravatar_url` like before. Pretty cool is also the
fact that an object can be passed directly to `gravatar_tag` if it responds to `gravatar_url`, like:

    # model:
    class User < ActiveRecord::Base
      gravatarify :size => 16, :secure => true
    end
    
    # view:
    <%= gravatar_tag @user %> # -> <img ... width="16" src="https://secure.gravatar..." height="16" />
    
The `gravatar_tag` looks if the object responds to `gravatar_url` and if so, just passes the options to it,
it works also with plain old ruby objects, of course :)

### PORO - plain old ruby objects (yeah, POJO sounds smoother :D)

Not using Rails, ActiveRecord or DataMapper? It's as easy as including `Gravatarify::ObjectSupport` to your
class:

    require 'gravatarify'
    class PoroUser
      include Gravatarify::ObjectSupport
      gravatarify
    end
    
Tadaaa! Works exactly like the model helpers, so it's now possible to call `gravatar_url` on instances
of `PoroUser`.

<a id="l_roots"/>
## Back to the roots?

No need for sophisticated stuff like view helpers and ActiveRecord integration, want to go back to the roots?
Then feel free to use `Gravatarify::Base#build_gravatar_url` directly.

For example, want to use `build_gravatar_url` in a Sinatra app?

    helpers Gravatarify::Base
    
Yeah, that should work :). See {Gravatarify::Base#build_gravatar_url} for more informations and usage examples.

## Need more control?

<table>
  <tr>
    <th>Option</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>:default</tt></td>
    <td>String, Proc</td>
    <td>Fully qualified URL to an image, which is used if gravatar.com has no image for the supplied email.
        <tt>Proc</tt>s can be used to return e.g. an image based on the request size (see Advanced stuff).
        Furthermore gravatar.com provides several "special values" which generate icons, these are "wavatar",
        "monsterid" and "identicon", finally if set to <tt>404</tt> gravatar.com returns the <tt>HTTP 404 Not Found</tt> error.
        If nothing is specified gravatar.com returns it's gravatar icon.
    </td>
    <td>-</td>
  </tr>
  <tr>
    <td><tt>:rating</tt></td>
    <td>String, Symbol</td>
    <td>Each avatar at gravatar.com has a rating associated (which is based on MPAAs rating system), valid values are:<br/>
        <b>g</b> - general audiences, <b>pg</b> - parental guidance suggested, <b>r</b> - restricted and <b>x</b> - x-rated :).
        Gravatar.com returns <b>g</b>-rated avatars, unless anything else is specified.
    </td>
    <td>-</td>
  </tr>
  <tr>
    <td><tt>:size</tt></td>
    <td>Integer</td>
    <td>Avatars are square, so <tt>:size</tt> defines the length of the sides in pixel, if nothing is specified gravatar.com
        returns 80x80px images.</td>
    <td>-</td>
  </tr>
  <tr>
    <td><tt>:secure</tt></td>
    <td>Boolean, Proc</td>
    <td>If set to <tt>true</tt> gravatars secure host (<i>https://secure.gravatar.com/</i>) is used to serve the avatars
      from. Can be a Proc to inflect wheter or not to use the secure host based on request parameters.</td>
    <td><tt>false</tt></td>
  </tr>
  <tr>
    <td><tt>:filetype</tt></td>
    <td>String, Symbol</td>
    <td>Change image type, gravatar.com supports <tt>:gif</tt>, <tt>:png</tt> and <tt>:jpg</tt>.</td>
    <td><tt>:jpg</tt></td>
  </tr>
</table>

## Not yet enough?

The `:default` option can be passed in a `Proc`, so this is certainly useful to for example
to generate an image url, based on the request size:

    # in an initializer
    Gravatarify.options[:default] = Proc.new do |options, object|
      "http://example.com/avatar-#{options[:size] || 80}.jpg"
    end
    
    # now each time a gravatar url is generated, the Proc is evaluated:
    @user.gravatar_url
    # => "http://0.gravatar.com/...jpg?d=http%3A%2F%2Fexample.com%2Fgravatar-80.jpg"
    @user.gravatar_url(:size => 16)
    # => "http://0.gravatar.com/...jpg?d=http%3A%2F%2Fexample.com%2Fgravatar-16.jpg&s=16"
    
Into the block is passed the options hash and as second parameter the object itself, so in the example above
`object` would be `@user`, might be useful!? Never used it, so I might remove the second argument...

Not only the `:default` option accepts a Proc, but also `:secure`, can be useful to handle cases where
it should evaluate against `request.ssl?` for example.

## About the code

Eventhough this library has less than 100 LOC, it's split into four files, maybe a bit
of an overkill, though I like neat and tidy classes :)

    lib/gravatarify.rb                      # loads the other files from lib/gravatarify
                                            # and hooks the necessary modules into
                                            # ActionView, ActiveRecord and DataMapper
                                            # (if available)
                                            
    lib/gravatarify/base.rb                 # Provides all logic required to generate
                                            # gravatar.com urls from an email address.
                                            # Check out Gravatarify::Base.build_gravatar_url,
                                            # this is the absolute core method.
                                            
    lib/gravatarify/object_support.rb       # Module which (when) included provides the
                                            # gravatarify class method to add a gravatar_url
                                            # to any object.
                                            
    lib/gravatarify/view_helper.rb          # Defines rails view helpers.

## Licence

Copyright (c) 2009 Lukas Westermann

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.