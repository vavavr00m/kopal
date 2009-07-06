module Kopal
  def self.draw_routes base_route = '/profile'
    base_route[-1] = ''  if base_route[-1].chr == '/'
    @@base_route = base_route
    #Minimum routes should be defined here.
    ActionController::Routing::Routes.draw do |map|
      map.kopal_route_root Kopal.base_route, :controller => "kopal/home", :action => 'index',
        :trailing_slash => true
      map.kopal_route_home "#{Kopal.base_route}/home/:action/:id", :controller => 'kopal/home',
        :trailing_slash => true
      map.kopal_route_home "#{Kopal.base_route}/home/:action/:id.:format",
        :controller => 'kopal/home', :trailing_slash => false
      map.kopal_route_organise "#{Kopal.base_route}/organise/:action/:id", :controller => 'kopal/organise',
        :trailing_slash => true
      map.kopal_route_connect "#{Kopal.base_route}/connect/:action/", :controller => 'kopal/connect',
        :trailing_slash => true
      map.kopal_route_feed "#{Kopal.base_route}/home/feed.kp.xml", :controller => 'kopal/home',
        :action => 'feed', :format => 'xml', :trailing_slash => false
    end
  end
  
  def self.base_route
   @@base_route
  end
  
  def self.route
    @routing ||= Kopal::Routing.new
  end
end

#Wrapper around named routes.
class Kopal::Routing
  #include ActionController::Routing::Routes.named_routes.instance_variable_get :@module
  ActionController::Routing::Routes.named_routes.install self

  def root hash = {}
    kopal_route_root_path hash
  end
 
  def home hash = {}
    hash[:controller] = 'kopal/home'
    return root if hash[:action].blank? or hash[:action] == 'index'
    kopal_route_home_path hash
  end

  def feed
    kopal_route_feed_path
  end
  
  def organise hash = {}
    hash[:controller] = 'kopal/organise'
    kopal_route_organise_path hash
  end

  #LATER: As per http://www.google.com/support/webmasters/bin/answer.py?answer=76329
  #"edit-profile" should be preferred over "edit_profile", Rails should have some
  #in-built support for matching :action => "edit-profile" to method edit_profile.
  def edit_profile
    organise :action => 'edit_profile'
  end

  def change_password
    organise :action => 'change_password'
  end

  #Usage:
  # * +Kopal.route.stylesheet 'home'+
  # * +Kopal.route.stylesheet :id => 'home'+
  def stylesheet hash = 'home'
    hash = {:id => hash} if hash.is_a? String
    home({:action => 'stylesheet', :id => hash, :trailing_slash => false})
  end

  #TODO: :format => recognise saved image format.
  def profile_image hash = {}
    hash.update :action => 'profile_image', :id =>
      Kopal::ProfileUser.new.feed.name.titlecase.gsub(/[\/\\\!\@\#\$\%\^\*\&\-\.\,\?]+/, ' ').
      gsub(' ', '').underscore, :format => 'jpeg', :trailing_slash => false
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

  def organise_friend hash = {}
    hash[:action] = 'friend'
    organise hash
  end

  #Get the controller instance.
  def self.ugly_hack value
    @@controller = value
  end

private

  def url_for options = {}
    def @@controller.params
      {}
    end
    @@controller.url_for options
  end
  
end

