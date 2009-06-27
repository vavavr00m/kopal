#== <tt>kopal_config.yml</tt>.
#<tt>kopal_config.yml</tt> contains configuration options for Kopal as a Hash, keys made of +:symbols+.
#[<tt>:authntication_method</tt>]
#  Default is +:builtin+, may have a *string* value containing
#  the name of authentication method of +ApplicationController+ which acts in following ways.
#  If the user is authenticated, this method should return true, otherwise should
#  authenticate the user (may redirect to the authentication page for authentication) and
#  return +false+ or +nil+.
#[<tt>:account_password</tt>] Required if +:authentication_method+ is +:builtin+.
#
#== Themes for Kopal.
# *work in progress, not yet implemented*
#=== Available @page variables.
#[<tt>@page.title</tt>] Title of the page. Goes in +<title></title>+
#[<tt>@page.description</tt>] Description of the page. Goes in +<meta name="Description" />+
#[<tt>@page.stylesheets</tt>] 
#  Path of stylesheets for page.
#  Example Usage - 
#  * +@page.stylesheets = 'home'+
#  * +@page.stylesheets = ['home', 'home2'] #Two stylesheets+
#  * +@page.stylesheets = [{:name => 'home'}, {:name => 'home2', :media => 'print'}]+
#
#=== Available containers
# * +:page_head_meta_content+
# * +:page_bottom_content+
# * +:surface_right_content+

require 'kopal/exception'
module Kopal
  include KopalHelper
  SOFTWARE_VERSION = "2009.0.1.alpha"
  #protocol right word? Or standard? sepcification?
  CONNECT_PROTOCOL_REVISION = "0.1.draft"
  FEED_PROTOCOL_REVISION = "0.1.draft"
  PLATFORM = "kopal.googlecode.com"
  @@pref_cache = {}
  @@initialised = false

class << self
  #It doesn't work.
  #Kopal.CONST and Kopal::CONST are different. Remove this method after this
  #message becomes part of a commit.
  def DISCOVERY_PROTOCOL_REVISION
    DeprecatedMethod.here "Use CONNECT_PROTOCOL_REVISION instead."
    CONNECT_PROTOCOL_REVISION
  end
  #Anything that needs to be run at the startup, goes here.
  def initialise
    return if @@initialised
    @@config = Kopal::Config.new
    @@initialised = true
  end

  def initialised?
    @@initialised
  end

  def config
    @@config
  end

  def authenticate_simple password
    raise "Authentication method is not simple" unless
      config.authentication_method == 'simple'
    raise "Password is nil. Please specify a password in environment.rb, " +
      "using Kopal.config.account_password = 'your-password' inside " +
      "Rails::Initializer.run block and restart " +
      "your server." if
      config.account_password.nil?
    return true if password == config.account_password
    return false
  end

  def [] index
    index = index.to_s
    @@pref_cache[index] ||= KopalPreference.get_field(index)
  end

  def []= index, value
    index = index.to_s
    @@pref_cache[index] = KopalPreference.save_field(index, value)
  end

  #Will we ever need it?
  def reload_preferences!
    @@pref_cache = {}
  end
  
  def fetch url
    Kopal::Antenna.broadcast(Kopal::Signal::Request.new(url))
  end
end
end
