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

require 'active_support'
require 'active_support/dependencies'

KOPAL_ROOT = File.expand_path(File.dirname(__FILE__) + '/..')
require KOPAL_ROOT + '/lib/core_extension/require'
ActiveSupport::Dependencies.autoload_paths << KOPAL_ROOT + '/lib'

#Kopal libraries
require_dependency 'kopal/exception'
require_dependency 'kopal/openid'
require_dependency 'kopal/routing'

module Kopal
  include KopalHelper
  SOFTWARE_VERSION = File.read(KOPAL_ROOT + '/VERSION.txt').strip
  #protocol right word? Or standard? sepcification?
  CONNECT_PROTOCOL_REVISION = "0.1.draft"
  FEED_PROTOCOL_REVISION = "0.1.draft"
  DEFAULT_PLATFORM = "kopal.googlecode.com"
  @@initialised = false
  @@multi_mode = false
  @@delegated_preferences = []
  @@delegated_preference_method = {}

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

  #Pass an hash with name of the class as string.
  #Example:
  #
  #    Kopal.delegate_some_preferences_to :class => "SomeModel"
  #
  #Optionally names of the getter and setter methods can also be supplied.
  #Example:
  #
  #  Kopal.delegate_some_preferences_to :class => "SomeModel", :accessor => 'get_field', :mutator => 'save_field'
  #
  #Default for <tt>:accessor</tt> is +get_field+ while for <tt>:mutator</tt> is +save_field+
  #
  #=== Accessor
  #The accessor method must take two arguments as -
  #
  #  accessor_method(profile_identifier, preference_name) # both argument as string
  #
  #It should return the value as String and should return +nil+ instead of raising error, if a
  #field is empty.
  #
  #=== Mutator
  #Signature for mutator method is -
  #
  #  mutator_method(profile_identifier, preference_name, new_preference_value) # all argument as string.
  #
  #It should return the saved value and should raise error if can not save.
  #Saved value shouldn't necessarily be same as provided value. For example, application
  #may calculate a new string for +account_password_salt+ and may discard supplied one.
  #
  def delegate_some_preferences_to hash
    @@delegated_preference_method = {
      :class => hash[:class],
      :accessor => (hash[:accessor] || 'get_field'),
      :mutator => (hash[:mutator] || 'save_field'),
    }
  end

  def preferences_delegated_to_application
    @@delegated_preferences
  end

  def delegated_preference_method
    @@delegated_preference_method
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
    DeprecatedMethod.here "Use path.root instead"
    path.root
  end

  def path
    Kopal::Path
  end

  def base_route
    return @base_route if @base_route
    @base_route = Rails.application.config.kopal.base_route
    @base_route[-1] = ''  if @base_route[-1].chr == '/'
    @base_route
  end

  def default_profile_user
    @default_profile_user ||= Kopal::ProfileUser.new(0)
  end
end
end
