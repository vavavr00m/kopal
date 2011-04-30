require 'rails'

module Kopal
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.join(KOPAL_RAILS_ROOT, 'lib', 'tasks', 'kopal.rake')
    end
  end
end