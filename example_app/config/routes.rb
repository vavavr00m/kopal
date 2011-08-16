ExampleApp::Application.routes.draw do
  #https://github.com/rails/rails/issues/2131
  #mount Kopal::Engine, :at => '/', :as => 'kopal'
  root :to => redirect('/profile')
  mount Kopal::Engine, :at => '/profile', :as => 'kopal'
end
