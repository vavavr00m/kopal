KOPAL_RAILS_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..')) unless
  defined? KOPAL_RAILS_ROOT

require 'active_support/dependencies' #FIXME: Why am I getting "uninitialized constant ActiveSupport::Dependencies" without it?
require_dependency File.join(File.dirname(__FILE__), '..', '..', 'kopal', 'lib', 'kopal')
require_dependency File.join(KOPAL_RAILS_ROOT, 'lib', 'kopal', 'rails_path').to_s

ActiveSupport::Dependencies.autoload_paths << KOPAL_RAILS_ROOT + '/lib'

require File.dirname(__FILE__) + '/../railtie'
require File.dirname(__FILE__) + '/../engine'

raise "Kopal requires Rails 3" unless Rails::VERSION::MAJOR == 3


#ActiveSupport::Dependencies.autoload_once_paths.delete KOPAL_ROOT unless Rails.env == "production"
ActiveSupport::Dependencies.explicitly_unloadable_constants << 'Kopal' unless Rails.env == "production"

#ActionController::Base.send :include, Kopal::Theme::Filter

%w{ models controllers }.each do |dir|
  path = File.join(File.dirname(__FILE__), '..', 'app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.autoload_paths << path
  ActiveSupport::Dependencies.autoload_once_paths.delete(path) unless Rails.env == "production"
end 