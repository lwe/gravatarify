# Gravatarify
    
Removes any hassles building those pesky gravatar urls, it's not there arent any alternatives [out](http://github.com/mdeering/gravitar_image_tag),
[there](http://github.com/chrislloyd/gravtastic), but none seem to support stuff like `Proc`s for the default picture url, or
the multiple host names supported by gravatar.com (great when displaying lots of avatars).

Best of it? It works with Rails, probably Merb and even plain old Ruby :)

## Install

TODO: need to gemify it...

## Using the view helpers

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

## Using the model helpers

Another way (especially cool) for models is to do:

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

