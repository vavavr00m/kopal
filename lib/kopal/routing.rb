module Kopal
  def self.draw_routes base_route = '/profile'
    base_route[-1] = ''  if base_route[-1].chr == '/'
    @@base_route = base_route
    #Minimum routes should be defined here.
    ActionController::Routing::Routes.draw do |map|
      if Kopal.base_route.blank?
        #Or else it will redirect to http://127.0.0.1:3500//
        map.kopal_route_root Kopal.base_route, :controller => 'kopal/home', :action => 'index',
          :trailing_slash => false
      else
        map.kopal_route_root Kopal.base_route, :controller => "kopal/home", :action => 'index',
          :trailing_slash => true
      end
      map.kopal_route_home "#{Kopal.base_route}/home/:action/:id", :controller => 'kopal/home',
        :trailing_slash => true
      map.kopal_route_home "#{Kopal.base_route}/home/:action/:id.:format",
        :controller => 'kopal/home', :trailing_slash => false
      map.kopal_route_page "#{Kopal.base_route}/page/*page", :controller => 'kopal/page',
        :trailing_slash => false
      map.kopal_route_page_draw "#{Kopal.base_route}/pagedraw/:action/:id",
        :controller => 'kopal/page_draw', :trailing_slash => true
      map.kopal_route_organise "#{Kopal.base_route}/organise/:action/:id", :controller => 'kopal/organise',
        :trailing_slash => true
      map.kopal_route_connect "#{Kopal.base_route}/connect/:action/", :controller => 'kopal/connect',
        :trailing_slash => true
      map.kopal_route_feed "#{Kopal.base_route}/home/feed.kp.xml", :controller => 'kopal/home',
        :action => 'feed', :format => 'xml', :trailing_slash => false
      map.namespace :kopal do |kopal|
        kopal.resource :widget_record, :path_prefix => base_route, :controller => 'WidgetRecord',
          :only => [:show, :create, :update, :destroy], :trailing_slash => true
      end
    end
  end

  #This method is intended for internal use only, prefer +Kopal.route.root+ instead.
  #Path of Kopal relative to host, and without postfixed '/'
  def self.base_route
   @@base_route
  end

end

#Wrapper around named routes.
#Should deprecate it, and use all routes from rails/routing instead?
#Do we really need a wrapper class? Justify.
class Kopal::Routing
  #include ActionController::Routing::Routes.named_routes.instance_variable_get :@module
  ActionController::Routing::Routes.named_routes.install self

  def initialize controller
    raise 'Tried to initialise from a non-kopal controller' unless
      controller.is_a? Kopal::ApplicationController
    @controller = controller
  end

  #Homepage of Kopal profile.
  def root hash = {}
    kopal_route_root_path hash
  end

  #Homepage of Kopal profile by default. Accpets actions of Kopal::HomeController
  def home hash = {}
    hash[:controller] = 'kopal/home'
    #FIXME: By default it goes false, in route_organise it stays true.
    hash[:trailing_slash].nil?() ? hash[:trailing_slash] = true : nil
    return root if hash[:action].blank? or hash[:action] == 'index'
    kopal_route_home_path hash
  end

  def profile_comment hash = {}
    home hash.update :action => 'comment'
  end

  def kopal_feed hash = {}
    kopal_route_feed_path hash
  end
  alias feed kopal_feed

  def kopal_connect hash = {}
    kopal_route_connect_path hash
  end
  alias connect kopal_connect

  #Usage:
  #    Kopal.route.page 'homepage'
  #    Kopal.route.page :page => 'homepage'
  def page hash = {}
    hash = {:page => hash} if hash.is_a? String
    hash[:trailing_slash] = !hash[:page]
    kopal_route_page_path hash
  end

  def page_draw hash = {}
    kopal_route_page_draw_path hash
  end

  #Or create_page?
  def page_create hash = {}
    page_draw hash.update :action => 'create_page'
  end

  #Or edit_page?
  def page_edit hash = {}
    hash = { :page => hash} if hash.is_a? String
    page_draw hash.update :action => 'edit'
  end

  def page_delete hash = {}
    hash = { :page => hash} if hash.is_a? String
    page_draw hash.update :action => 'delete_page'
  end

  def organise hash = {}
    hash[:controller] = 'kopal/organise'
    kopal_route_organise_path hash
  end

  #+:only_path+ is true by default.
  def xrds hash = {}
    home hash.update :action => 'xrds', :only_path => !!hash[:only_path]
  end

  alias yadis xrds

  def openid_consumer hash = {}
    home hash.update :action => 'openid'
  end

  #+:only_path+ is true by default.
  def openid_consumer_complete hash = {}
    #params[:openid_complete] = 1
    openid_consumer hash.update :only_path => !!hash[:only_path]
  end

  #+:only_path+ is true by default.
  def openid_server hash = {}
    hash[:only_path] = !!hash[:only_path] #Default is false.
    home hash.update :action => 'openid_server'
  end

  #LATER: As per http://www.google.com/support/webmasters/bin/answer.py?answer=76329
  #"edit-identity" should be preferred over "edit_identity", Rails should have some
  #in-built support for matching :action => "edit-identity" to method edit_identity.
  def edit_identity hash = {}
    organise hash.update :action => 'edit_identity'
  end

  def change_password hash = {}
    organise hash.update :action => 'change_password'
  end

  #Usage:
  # * +Kopal.route.stylesheet 'home'+
  # * +Kopal.route.stylesheet :id => 'home', :dont_cache => Time.now+
  def stylesheet hash = 'home'
    hash = {:id => hash} if hash.is_a? String
    hash.update :action => 'stylesheet', :format => 'css', :trailing_slash => false
    home(hash)
  end

  def javascript hash = 'home'
    hash = { :id => hash} if hash.is_a? String
    home hash.update :action => 'javascript', :format => 'js', :trailing_slash => false
  end

  #Unlike stylesheet and javascript, need to pass the file extension too.
  #Ex:
  #    image "ajax-spinner.gif"
  def image hash = {}
    hash = { :id => hash} if hash.is_a? String
    home hash.update :action => 'image', :trailing_slash => false
  end

  #TODO: :format => recognise saved image format.
  #pass a custome name as as hash[:image_name]
  def profile_image hash = {}
    image_name = hash.delete(:image_name) ||
      @controller.instance_variable_get(:@profile_user).feed.name.titlecase.
        gsub(/[\/\\\!\@\#\$\%\^\*\&\-\.\,\?]+/, ' ').gsub(' ', '').underscore
    hash.update :action => 'profile_image', :id =>
      image_name, :format => (hash[:format] || 'jpeg'), :trailing_slash => false
    home(hash)
  end

  def signin hash = {}
    hash.update :action => 'signin'
    home(hash)
  end

  def signout hash = {}
    hash.update :action => 'signout'
    home(hash)
  end

  def kopal_feed hash = {}
    kopal_feed_path hash
  end

  def friend hash = {}
    hash[:action] = 'friend'
    hash[:trailing_slash] = false unless hash[:id].blank?
    home hash
  end

  #@deprecated. Use organise(:action => 'friend') instead.
  #Originally thought that API should be independent of
  #uri i.e., knowing name of action etc, but that is overkill.
  def organise_friend hash = {}
    hash[:action] = 'friend'
    organise hash
  end

private

  def url_for options = {}
    @controller.url_for options
  end

end

