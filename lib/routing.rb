module Kopal
  def self.draw_routes base_route = '/profile'
    base_route[-1] = ''  if base_route[-1].chr == '/'
    @@base_route = base_route
    #Minimum routes should be defined here.
    ActionController::Routing::Routes.draw do |map|
      map.kopal_root Kopal.base_route, :controller => "home", :action => 'index'
      map.kopal_route "#{Kopal.base_route}/:controller/:action/:id",
        :trailing_slash => true #OR, :defaults => {:trailing_slash => true}
      map.kopal_route "#{Kopal.base_route}/:controller/:action/:id.:format",
        :trailing_slash => false
      map.kopal_feed "#{Kopal.base_route}/home/feed.kp.xml", :controller => 'home', :action => 'feed',
        :format => 'xml', :trailing_slash => false
    end
  end
  
  def self.base_route
   @@base_route
  end
  
  def self.route
    Kopal::Routing
  end
end

module Kopal::Routing
 
class << self

  def root
    kopal_root_path
  end
 
  def home parameters = {}
    parameters[:controller] = 'home'
    return root if parameters[:action].blank? or parameters[:action] == 'index'
    kopal_route_path parameters
  end
  
  def organise parameters = {}
    parameters[:controller] = 'organise'
    kopal_route_path parameters
  end
  
  def sylesheet name = 'home'
    home({:action => 'stylesheet', :action => name, :format => 'css'})
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
  
end
end

