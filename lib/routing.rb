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
      map.kopal_route_organise "#{Kopal.base_route}/organise/:action/:id", :controller => 'kopal/organise',
        :trailing_slash => true
      map.kopal_route_connect "#{Kopal.base_route}/connect/:action/", :controller => 'kopal/connect',
        :trailing_slash => true
      map.kopal_route_stylesheet "#{Kopal.base_route}/home/stylesheet/:id.css",
        :controller => 'kopal/home', :action => 'stylesheet', :trailing_slash => false
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

class Kopal::Routing
  #include ActionController::Routing::Routes.named_routes.instance_variable_get :@module
  ActionController::Routing::Routes.named_routes.install self

  def root
    kopal_route_root_path
  end
 
  def home parameters = {}
    parameters[:controller] = 'kopal/home'
    return root if parameters[:action].blank? or parameters[:action] == 'index'
    kopal_route_home_path parameters
  end

  def feed
    kopal_route_feed_path
  end
  
  def organise parameters = {}
    parameters[:controller] = 'kopal/organise'
    kopal_route_organise_path parameters
  end
  
  def stylesheet name = 'home'
    kopal_route_stylesheet_path({:id => name, :trailing_slash => false})
  end

  def signin
    home(:action => 'signin')
  end

  def signout
    home(:action => 'signout')
  end
  
  def kopal_feed
    kopal_feed_path
  end
  
  def friend parameters = {}
    parameters[:action] = 'friend'
    parameters[:trailing_slash] = false unless parameters[:id].blank?
    home parameters
  end

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

