Kopal::Engine.routes.draw do 
  
  namespace :sign do
    get 'in'
    post 'in_for_visiting_user'
    get 'in_for_visiting_user'
    post 'in_for_profile_user'
    delete 'out'
  end
  
  match '/asset' => "home#siterelated"
  match '/home((/:action)/:id)', :controller => 'home', :as => 'home'
  
  namespace :organise do
    resources :profiles, :path => 'profile' do
      resources :pages, :path => 'page'
    end
  end
  
  nested_in_profiles = Proc.new do
    namespace :connect do
    end
    match '/xrds' => "home#xrds"
    match "/feed.kp.xml" => "home#feed", :format => 'xml'
    resources :profile_comments, :path => 'comment'
    resource :widget_record, :only => [:show, :create, :update, :destroy], :trailing_slash => true
    namespace :organise do
      resources :pages, :path => 'page'
    end
    match "/page/(:page)" => "home#page", :constraints => {:page => /.+/ }
  end
  
  if Kopal::Engine::spi?
      nested_in_profiles.call
  else
    resources :profiles, :path => '', :only => [] do
      nested_in_profiles.call
    end
  end
  
  root :to => "home#index"
end