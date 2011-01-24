require 'rails'
require 'kopal'

module Kopal
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/kopal.rake"
    end
  end
end