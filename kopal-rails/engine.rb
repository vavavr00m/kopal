require 'rails'
require_dependency 'kopal'

module Kopal
  #Should it rather be ::Kopal::Rails::Engine to differentiate Rails specific
  #classes with core classes?
  class Engine < Rails::Engine
    config.autoload_paths << File.join(KOPAL_ROOT, 'lib')
    config.autoload_paths << File.join(KOPAL_ROOT, 'rails', 'lib')
    paths.config.routes = Kopal.path.rails.routes.to_s

    config.before_configuration do
      config.kopal = ActiveSupport::OrderedOptions.new
      config.kopal.base_route = "/profile"
    end

    config.to_prepare do
      #This block runs on every request in development
      #and only once in production as per http://www.engineyard.com/blog/2010/extending-rails-3-with-railties/
      #Maybe we should use this for getting Kopal in unloadable constants.
    end
  end
end