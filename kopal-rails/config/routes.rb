Rails.application.routes.draw do |map|
  if Kopal.base_route.blank?
    #Or else it will redirect to http://127.0.0.1:3500//
    map.kopal_root Kopal.base_route, :controller => 'kopal/home', :action => 'index',
      :trailing_slash => false
  else
    map.kopal_root Kopal.base_route, :controller => "kopal/home", :action => 'index',
      :trailing_slash => true
  end
  
  map.kopal_route_home "#{Kopal.base_route}/home/:action/:id", :controller => 'kopal/home',
    :trailing_slash => true
  #:trailing_slash => false makes whole "/profile/" unrecognisable in Rails 3.
  #However, I couldn't reproduce it in a new application (both using rails 3.0.3).
#  map.kopal_route_home "#{Kopal.base_route}/home/:action/:id.:format",
#    :controller => 'kopal/home', :trailing_slash => false
  map.kopal_route_home "#{Kopal.base_route}/home/:action/:id.:format",
    :controller => 'kopal/home', :trailing_slash => true

  match "page(/*page)" => "kopal/page\#index", :as => 'kopal_route_page'
  map.kopal_route_page_draw "#{Kopal.base_route}/pagedraw/:action/:id",
    :controller => 'kopal/page_draw', :trailing_slash => true
  map.kopal_route_organise "#{Kopal.base_route}/organise/:action/:id", :controller => 'kopal/organise',
    :trailing_slash => true
  map.kopal_route_connect "#{Kopal.base_route}/connect/:action/", :controller => 'kopal/connect',
    :trailing_slash => true
  map.kopal_route_feed "#{Kopal.base_route}/home/feed.kp.xml", :controller => 'kopal/home',
    :action => 'feed', :format => 'xml', :trailing_slash => false
  scope Kopal.base_route, :as => 'kopal', :module => 'kopal' do
    namespace :home do
      get 'xrds'
    end
    namespace :sign do
      get 'in'
      post 'in_for_visiting_user'
      get 'in_for_visiting_user'
      post 'in_for_profile_user'
      delete 'out'
    end
    resources :profile_comments, :path => 'comment'
    resource :widget_record, :only => [:show, :create, :update, :destroy], :trailing_slash => true
  end
end