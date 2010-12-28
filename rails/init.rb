require 'active_support/dependencies' #FIXME: Why am I getting "uninitialized constant ActiveSupport::Dependencies" without it?
require File.dirname(__FILE__) + '/railtie'

ActiveSupport::Dependencies.autoload_paths << File.join(KOPAL_ROOT, 'lib')
#ActiveSupport::Dependencies.autoload_once_paths.delete KOPAL_ROOT unless Rails.env == "production"
ActiveSupport::Dependencies.explicitly_unloadable_constants << 'Kopal' unless Rails.env == "production"

#ActionController::Base.send :include, Kopal::Theme::Filter

%w{ models controllers }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.autoload_paths << path
  ActiveSupport::Dependencies.autoload_once_paths.delete(path) unless Rails.env == "production"
end 