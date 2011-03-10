require 'rails'
require 'mongoid'
require_dependency 'kopal'

module Kopal
  #Should it rather be ::Kopal::Rails::Engine to differentiate Rails specific
  #classes with core classes?
  #TODO: Check on initialisation if Kopal is set-up, if not raise error and ask user
  #      to run kopal:first_time or if updated recently, upgrade automatically if there are stuffs.
  class Engine < Rails::Engine
    config.autoload_paths << File.join(KOPAL_ROOT, 'lib')
    config.autoload_paths << File.join(KOPAL_ROOT, 'rails', 'lib')
    paths.config.routes = File.join(KOPAL_RAILS_ROOT, 'config', 'routes.rb')

    config.before_configuration do
      config.kopal = ActiveSupport::OrderedOptions.new
      config.kopal.base_route = "/profile"
      config.kopal.multiple_profile_interface = false
      config.kopal.default_profile_identifier = "default"
      config.kopal.collection_prefix = "kopal_"
    end

    config.to_prepare do
      #This block runs on every request in development
      #and only once in production as per http://www.engineyard.com/blog/2010/extending-rails-3-with-railties/
      #Maybe we should use this for getting Kopal in unloadable constants.
    end
  end
end
