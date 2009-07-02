# Copied from helpers/route_helper.rb
#  def signin_path
#    home_path(:action => 'signin')
#  end
#
#  def signout_path
#    home_path(:action => 'signout')
#  end
#
#  def friend_path hash = {}
#    hash[:action] = 'friend'
#    home_path hash
#  end
# Create stylesheet_path()
# 

module Kopal
  module Routing
    module MapperExtensions
      def kopal base = '/profile/'
        @set.add_route(base, {:controller => 'home_controller', :action => 'index'})
      end
    end
  end
end
#ActionController::Routing::RouteSet::Mapper.send :include, Kopal::Routing::MapperExtensions

module Kopal
  def self.draw_routes base_route = '/profile'
    base_route[-1] = ''  if base_route[-1].chr == '/'
    @@base_route = base_route
    ActionController::Routing::Routes.draw do |map|
      map.kopal_root Kopal.base_route, :controller => "home", :action => 'index'
      map.kopal_home "#{Kopal.base_route}/home/:action/:id", :controller => 'home', :trailing_slash => true
      map.kopal_feed "#{Kopal.base_route}/home/feed.kp.xml", :controller => 'home', :action => 'feed',
        :format => 'xml', :trailing_slash => false
      map.kopal_organise "#{Kopal.base_route}/organise/:action/:id", :controller => 'organise', :trailing_slash => true
    end
  end
  
  def self.base_route
   @@base_route
  end
end
