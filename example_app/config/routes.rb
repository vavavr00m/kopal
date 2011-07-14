ExampleApp::Application.routes.draw do
  mount Kopal::Engine, :at => '/', :as => 'kopal'
end
