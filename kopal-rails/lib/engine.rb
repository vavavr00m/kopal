require 'rails'
require 'mongoid'
require_dependency 'kopal'

module Kopal
  #Should it rather be ::Kopal::Rails::Engine to differentiate Rails specific
  #classes with core classes?
  #TODO: Check on initialisation if Kopal is set-up, if not raise error and ask user
  #      to run kopal:first_time or if updated recently, upgrade automatically if there are stuffs.
  class Engine < Rails::Engine
    paths.config.routes = File.join(KOPAL_RAILS_ROOT, 'config', 'routes.rb')
    #I18n::UnknownFileType: can not load translations from <path>/kopal-rails/config/culture, the file type  is not known
    #paths.config.locales = File.join(KOPAL_RAILS_ROOT, 'config', 'culture')
    config.i18n.load_path += Dir[File.join(KOPAL_RAILS_ROOT, 'config', 'culture', '*.{rb,yml}')]

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
