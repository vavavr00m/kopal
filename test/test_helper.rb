ENV["RAILS_ENV"] = "test"
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/../../../..' 
require 'test/unit'
require File.expand_path(File.join(ENV['RAILS_ROOT'], 'config/environment.rb'))
require 'test_help'

def load_schema
  ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
  Kopal::Database.establish_connection
  Kopal::Database.migrate
end

class ActiveSupport::TestCase
  load_schema
  # Add more helper methods to be used by all tests here...
end
