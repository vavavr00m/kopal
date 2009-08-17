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

KOPAL_ROOT = File.expand_path(File.dirname(__FILE__) + '/..')

#Gems and plugins
require 'will_paginate'
require KOPAL_ROOT + '/vendor/recaptcha/init'

#Kopal libraries
require_dependency 'core_extension'
require_dependency KOPAL_ROOT + '/config_dependency'
require_dependency 'kopal/exception'
require_dependency 'kopal/openid'
require_dependency 'routing'

%w{ models controllers }.each do |dir| 
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.load_paths << path
  ActiveSupport::Dependencies.load_once_paths.delete(path) #if RAILS_ENV == 'development'
end 

module Kopal
  include KopalHelper
  SOFTWARE_VERSION = "2009.0.alpha.1"
  #protocol right word? Or standard? sepcification?
  CONNECT_PROTOCOL_REVISION = "0.1.draft"
  FEED_PROTOCOL_REVISION = "0.1.draft"
  PLATFORM = "kopal.googlecode.com"
  @@pref_cache = {}
  @@initialised = false

class << self
  
  #Anything that needs to be run at the startup, goes here.
  def initialise
    return if @@initialised
    @@initialised = true
  end

  def initialised?
    @@initialised
  end
  
  #These four methods sound similar, but have different usages.
  #  Kopal.root (File system path of Kopal plugin).
  #  Kopal.route.root (URL of homepage of Kopal Identity).
  #  Kopal.base_route (Do not use. For internal use only.) [Without postfixed '/']
  #  Kopal.identity (May be different than Kopal.route.root, if saved such in database).
  def root
    Pathname.new KOPAL_ROOT
  end

  #Kopal Identity of the user.
  def identity
    profile_user.kopal_identity
  end

  def profile_user
    @profile_user ||= Kopal::ProfileUser.new
  end

  def authenticate_simple password
    raise "Authentication method is not simple" unless
      Kopal[:authentication_method] == 'simple'
    raise "Password is nil!" if Kopal[:account_password].blank?
    return true if password == Kopal[:account_password]
    return false
  end

  #Indexes KopalPreference
  def [] index
    index = index.to_s
    @@pref_cache[index] ||= Kopal::KopalPreference.get_field(index)
  end

  def []= index, value
    index = index.to_s
    @@pref_cache[index] = Kopal::KopalPreference.save_field(index, value)
  end

  #Will we ever need it?
  def reload_preferences!
    @@pref_cache = {}
  end

  #Fetches a given URL and returns a Kopal::Signal::Response
  def fetch url
    Kopal::Antenna.broadcast(Kopal::Signal::Request.new(url))
  end
end
end
