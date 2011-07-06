#Not loading automatically
require 'mongoid'
require 'formtastic'

Kopal #Load the 'kopal' gem.
module Kopal
  #Should it rather be ::Kopal::Rails::Engine to differentiate Rails specific
  #classes with core classes from "kopal" gem?
  #TODO: Check on initialisation if Kopal is set-up, if not raise error and ask user
  #      to run kopal:first_time or if updated recently, upgrade automatically if there are stuffs.
  class Engine < Rails::Engine
    isolate_namespace Kopal
    
    #I18n::UnknownFileType: can not load translations from <path>/kopal-rails/config/culture, the file type  is not known
    #paths["config/locales"] = "config/culture"
    #Doesn't load anything.
    #paths["config/locales"] = "config/culture/*.{rb,yml}"
    config.i18n.load_path += Dir[File.join(config.root, 'config', 'culture', '*.{rb,yml}')]
    
    config.autoload_paths += %W(#{config.root}/lib)

    config.before_configuration do
      config.kopal = ActiveSupport::OrderedOptions.new
      config.kopal.multiple_profile_interface = false
      config.kopal.default_profile_identifier = "default"
      config.kopal.collection_prefix = "kopal_"
    end

    class << self
      def multiple_profile_interface?
        Rails.application.config.kopal.multiple_profile_interface
      end
      
      def single_profile_interface?
        not multiple_profile_interface?
      end
      alias spi? single_profile_interface?
    end
  end
end
