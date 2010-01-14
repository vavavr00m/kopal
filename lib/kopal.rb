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
#=== Available @_page variables. See Kopal::PageView for more information.
#[<tt>@_page.title</tt>] Title of the page. Goes in +<title></title>+
#[<tt>@_page.description</tt>] Description of the page. Goes in +<meta name="Description" />+
#[<tt>@_page.stylesheets</tt>]
#  Path of stylesheets for page.
#  Example Usage - 
#  * @_page.add_stylesheet 'home'
#  * @_page.add_stylesheet {:name => 'home2'}
#  * @_page.add_stylesheet {:name => 'home2', :media => 'print'}
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
require_dependency 'kopal/routing'

%w{ models controllers }.each do |dir| 
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.load_paths << path
  ActiveSupport::Dependencies.load_once_paths.delete(path) #if RAILS_ENV == 'development'
end 

module Kopal
  include KopalHelper
  SOFTWARE_VERSION = File.read(KOPAL_ROOT + '/VERSION.txt').strip
  #protocol right word? Or standard? sepcification?
  CONNECT_PROTOCOL_REVISION = "0.1.draft"
  FEED_PROTOCOL_REVISION = "0.1.draft"
  PLATFORM = "kopal.googlecode.com"
  @@initialised = false
  @@multi_mode = false
  @@delegated_signin = false

class << self
  
  attr_accessor :redirect_for_home
  
  #Anything that needs to be run at the startup, goes here.
  def initialise
    return if @@initialised
    @@initialised = true
  end

  def initialised?
    @@initialised
  end
  
  def multiple_profile_interface!
    @@multi_mode = true
  end

  #aliased as multi_mode?
  def multiple_profile_interface?
    @@multi_mode
  end

  alias multi_mode? multiple_profile_interface?

  #Not necessarily in only multi mode.
  def delegate_signin_to_application!
    @@delegated_signin = true
  end

  def delegate_signin_to_application?
    @@delegated_signin
  end

  def khelper #helper() is defined for ActionView::Base
    #Need to use "module_function()" in Kopal::KopalHelper,
    #but that would make all methods as private instance methods,
    #so need to completely deprecate and remove Kopal::KopalHelperWrapper first.
    @khelper ||= Kopal::KopalHelperWrapper.new
  end
  
  #These four methods sound similar, but have different usages.
  #  Kopal.root (File system path of Kopal plugin).
  #  Kopal.route.root (URL of homepage of Kopal Identity).
  #  Kopal.base_route (Do not use. For internal use only.) [Without postfixed '/']
  def root
    Pathname.new KOPAL_ROOT
  end

  def default_profile_user
    @default_profile_user ||= Kopal::ProfileUser.new(0)
  end
end
end
